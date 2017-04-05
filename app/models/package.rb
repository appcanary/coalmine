# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  platform       :string           not null
#  release        :string
#  name           :string           not null
#  version        :string
#  source_name    :string
#  source_version :string
#  epoch          :string
#  arch           :string
#  filename       :string
#  checksum       :string
#  origin         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  valid_at       :datetime         not null
#  expired_at     :datetime         default("infinity"), not null
#
# Indexes
#
#  index_packages_on_expired_at                                 (expired_at)
#  index_packages_on_name_and_version_and_platform_and_release  (name,version,platform,release)
#  index_packages_on_valid_at                                   (valid_at)
#

# A package is unique across (name, platform, release, version)
# todo: track if submitted from users?
class Package < ActiveRecord::Base
  has_many :bundled_packages, :dependent => :destroy
  has_many :bundles, :through => :bundled_packages
  has_many :vulnerable_packages, :dependent => :destroy
  has_many :vulnerable_dependencies, :through => :vulnerable_packages
  has_many :vulnerabilities, :through => :vulnerable_packages
  has_many :advisories, :through => :vulnerabilities

  has_many :log_resolutions
  has_many :ignored_packages

  # validates_uniqueness_of :version, scope: [:platform, :release, :name]

  scope :pluck_unique_fields, -> { 
    select("name, version").pluck(:name, :version)
  }

  # this scope doesn't include package/release because
  # it is only used in PackageMaker, which takes package/release
  # as an input, and scopes the whole query to those values.
  scope :search_unique_fields, ->(values) {
    clauses = values.map do |vals|
      '(name = ? AND version = ?)'
    end

    where(clauses.join(" OR "), *values.flatten)
  }

  # affected means any package flagged at all.
  # we join on vuln_dep rather than vuln_pkg to
  # make chaining with VulnDep.patchable predictably easy
  scope :affected, -> {
    joins(:vulnerable_dependencies)
  }

  scope :affected_but_patchable, -> {
    affected.merge(VulnerableDependency.patchable)
  }

  # find all vulnerable dependencies that *could* affect this package
  # we perform a broad search at first and perform the exact package matching
  # in ruby land
  def concerning_vulnerabilities
    if self.source_name
      VulnerableDependency.where(:platform => platform).where("package_name = ? OR package_name = ?", self.name, self.source_name)
    else
      VulnerableDependency.where(:platform => platform, :package_name => self.name)
    end
  end

  def same_name?(dep_name)
    self.source_name == dep_name || self.name == dep_name
  end

  # Given a list of affected version constraints,
  # is our version affected?

  def affected?(affected_version_constraints)
    # binding.pry unless affected_version_constraints.empty?
    affected_version_constraints.any? do |vc|
      version_satisfies?(vc)
    end
  end

  # Given a list of unaffected versions,
  # is our version greater than or equal any of 
  # the "unaffected" constraints?

  def not_affected?(unaffected_versions)
    unaffected_versions.any? do |v|
      version_satisfies?(v)
    end
  end

  # Given a list of version that have been patched,
  # is our version greater than or equal to any of
  # the "patched" contraints?

  def been_patched?(patched_versions)
    patched_versions.any? do |v|
      version_satisfies?(v)
    end
  end

  def version_satisfies?(version_constraint)
    comparator.satisfies?(version_constraint)
  end

  def comparator
    @comparator ||= Platforms.comparator_for(self)
  end

  # TODO needs test
  def upgrade_to
    @upgrade_to ||= calc_upgrade_to(self.vulnerable_dependencies.pluck(:patched_versions, :affected_versions))
  end

  def upgrade_to_given(vd)
    calc_upgrade_to([[vd.patched_versions, vd.affected_versions]])
  end

  # takes in an array of arrays
  # i.e. vuln_deps' patched_versions
  def calc_upgrade_to(patched_and_affected)
    patched = patched_and_affected.map(&:first)
    affected = patched_and_affected.map(&:last)
    case self.platform
    when Platforms::Ruby
      calc_ruby_upgrade_to(patched)
    when Platforms::PHP
      calc_php_upgrade_to(affected)
    else
      all_patches = patched.flatten
      [all_patches.max { |a,b| comparator.vercmp(a,b) }]
    end
  end

  def calc_php_upgrade_to(affected)
    constraint = affected.
                   reject(&:empty?).
                   find { |vc| comparator.satisfies?(vc) }.
                   try(:last)

    return nil unless constraint.present?

    parts = /^([^\d]+)(.*)$/.match(constraint)

    case parts[1]
    when "<"
      ["~#{parts[2]}"]
    when "<="
      ["~#{parts[2]},>#{parts[2]}"]
    else
      ["¯\_(ツ)_/¯"]
    end
  end

  def calc_ruby_upgrade_to(vds_pv)
    # TODO:
    #
    # argh basically have to replicate vd.affects? but
    # with these adhoc objects. punt for now.
    #
    # in an ideal world, we just check against all
    # the versions available in Rubygems proper.
    #
    # Instead, we hack it:

    # load every patch requirement into its object
    all_patches = vds_pv.map { |vdpv|
      vdpv.map { |pv|  Gem::Requirement.new(*pv.split(', ')) }
    }

    this_version = Gem::Version.new(self.version)
    # Gem::Requirement cleanly converts requirements
    # into Version objects.
    #
    # 1. Let's flatten this array of arrays
    # 2. map it from G::R to G::V
    # 3. flatten again & sort the versions,
    # 4. reject the ones that precede this version
    all_versions = all_patches.flatten.map { |gr| gr.requirements.map(&:last) }.flatten.sort.select { |v| this_version < v }


    # now we find the lowest common denominator,
    # by iterating through the list of sorted versions
    # (yielded by the list of requirements)
    # and finding the first version that matches any
    # of the patched_versions in *every single one*
    # of the vulnerable dependencies we find
    lcd = all_versions.find do |v|
      satisfies = all_patches.all? do |pvs|
        pvs.any? { |gr|
          gr === v
        }
      end
    end


    # Gem::Version().to_json causes
    # infinite recursion for some reason?
    # just call it to_s first
    [lcd.to_s]

  end

  # ----- view layer show highest vuln priority
  # perf hack for bundle/show
  # returns a hash! of just the attributes we need,
  # avoiding instantiating a whole AR::Base object
  #
  # This eliminated about 30% of sql calls in bundle/show
  def vulnerabilities_by_criticality
    @vulns_by_priority ||= pluck_to_hash(self.vulnerabilities.order_by_criticality, 
                                         :id, :criticality, :title)
  end

  def upgrade_priority_ordinal
    @upgrade_priority_ordinal ||= vulnerabilities_by_criticality.first.try(:[], :criticality)
  end

  def upgrade_priority
    Advisory::CRITICALITIES_BY_VALUE[upgrade_priority_ordinal]
  end

  # silly optimization
  def pluck_to_hash(q, *keys)
    q.pluck(*keys).map{|pa| Hash[keys.zip(pa)]}
  end


  # ----- view stuff
  def display_name
    "#{name} #{version}"
  end

  # ----- helps w/testing
  def to_simple_h
    {name: name, version: version}
  end

  # used solely for testing
  def to_pkg_builder
    Parcel.from_package(self)
  end
  
  def self.resolution_log_primary_key
    "packages.id"
  end
end

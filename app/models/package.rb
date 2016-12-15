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
  has_many :bundled_packages
  has_many :bundles, :through => :bundled_packages
  has_many :vulnerable_packages
  has_many :vulnerable_dependencies, :through => :vulnerable_packages
  has_many :vulnerabilities, :through => :vulnerable_packages
  has_many :advisories, :through => :vulnerabilities
  
  has_many :log_resolutions

  validates_uniqueness_of :version, scope: [:platform, :release, :name]

  scope :pluck_unique_fields, -> { 
    select("name, version").pluck(:name, :version)
  }

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

  # Given a list of unaffected versions,
  # is our version greater than or equal any of 
  # the "unaffected" constraints?

  def not_affected?(unaffected_versions)
    unaffected_versions.any? do |v|
      version_matches?(v)
    end
  end

  # Given a list of version that have been patched,
  # is our version greater than or equal to any of
  # the "patched" contraints?

  def been_patched?(patched_versions)
    patched_versions.any? do |v|
      version_matches?(v)
    end
  end

  def version_matches?(other_version)
    comparator.matches?(other_version)
  end

  def earlier_version?(pv)
    comparator.earlier_version?(pv)
  end

  def comparator
    @comparator ||= Platforms.comparator_for(self)
  end

  # TODO needs test
  def upgrade_to
    @upgrade_to ||= calc_upgrade_to(self.vulnerable_dependencies)
  end

  def upgrade_to_given(vd)
    calc_upgrade_to([vd])
  end

  def calc_upgrade_to(vds)

    if self.platform != Platforms::Ruby
      all_patches = vds.map(&:patched_versions).flatten
      [all_patches.sort { |a,b| comparator.vercmp(a,b) }.last]
    else

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
      all_patches = vds.map { |vd|
        vd.patched_versions.map { |pv|  Gem::Requirement.new(*pv.split(', ')) }
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

  end

  # ----- view layer show highest vuln priority
  def vulnerabilities_by_criticality
    @vulns_by_priority ||= self.vulnerabilities.order(criticality: :desc)
  end

  def upgrade_priority
    vulnerabilities_by_criticality.first.try(:criticality)
  end

  def upgrade_priority_ordinal
    Vulnerability.criticalities[upgrade_priority]
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

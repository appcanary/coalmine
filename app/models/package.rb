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

  # (defmethod upgrade-to :artifact.kind/rubygem
  # [vuln version]
  # (let [patched-versions (:patched-versions vuln)
  #       number (:number version)]
  #   (filter (fn [version-patch]
  #             (< (cmp-versions number (version-number version-patch)) 0))
  #           patched-versions)))


  # TODO needs test
  def upgrade_to
    @upgrade_to ||= calc_upgrade_to(self.vulnerable_dependencies)
  end

  def upgrade_to_given(vd)
    calc_upgrade_to([vd])
  end

  def calc_upgrade_to(vds)
    vds.map(&:patched_versions).reduce([]) do |arr, pv|
      pv.each do |v|
        arr << v if earlier_version?(v)
      end
      arr
    end
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

end

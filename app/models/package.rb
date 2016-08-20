# == Schema Information
#
# Table name: packages
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  source_name     :string
#  platform        :string
#  release         :string
#  version         :string
#  version_release :string
#  epoch           :string
#  arch            :string
#  filename        :string
#  checksum        :string
#  origin          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  valid_at        :datetime         not null
#  expired_at      :datetime         default("infinity"), not null
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

  # TODO: validate centos package format?

  def concerning_vulnerabilities
    # TODO: what do we store exactly on Vulns,
    # i.e. do we store name, platform, release?
    VulnerableDependency.where(:package_name => name, 
                               :package_platform => platform)
  end

  def same_name?(pkg_name)
    if self.platform == Platforms::Debian
      self.source_name == pkg_name
    else
      self.name == pkg_name 
    end
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

  # following two simplify testing
  def to_simple_h
    {name: name, version: version}
  end

  # used solely for testing
  def to_pkg_builder
    Parcel.from_package(self)
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
      pv.each do |pv|
        arr << pv if earlier_version?(pv)
      end
      arr
    end
  end

end

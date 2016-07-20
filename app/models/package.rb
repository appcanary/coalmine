# == Schema Information
#
# Table name: packages
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  source_name :string
#  platform    :string
#  release     :string
#  version     :string
#  artifact    :string
#  epoch       :string
#  arch        :string
#  filename    :string
#  checksum    :string
#  origin      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  valid_at    :datetime         not null
#  expired_at  :datetime         default("infinity"), not null
#

# A package is unique across (name, platform, release, version)
class Package < ActiveRecord::Base
  has_many :bundled_packages
  has_many :bundles, :through => :bundled_packages
  has_many :vulnerable_packages
  has_many :vulnerabilities, :through => :vulnerable_packages
  has_many :advisories, :through => :vulnerabilities

  validates_uniqueness_of :version, scope: [:platform, :release, :name]

  def concerning_vulnerabilities
    # TODO: what do we store exactly on Vulns,
    # i.e. do we store name, platform, release?
    VulnerableDependency.where(:package_name => name, 
                               :package_platform => platform)
    # Vulnerability.where("? = ANY(package_names)", name).where(:package_platform => platform)
  end

  def same_name?(pkg_name)
    if self.platform == Platforms::Debian
      self.source_name == pkg_name
    else
      self.name == pkg_name 
    end
  end

  def affected?(unaffected_versions)
    unaffected_versions.any? do |v|
      !same_version?(v)
    end
  end

  # TODO: has this been tested?
  def needs_patch?(patched_versions)
    patched_versions.any? do |v|
      !same_version?(v)
    end
  end

  # todo: better name for this
  def same_version?(other_version)
    comparator.matches?(other_version)
  end

  def comparator
    @comparator ||= Platforms.comparator_for(self.platform).new(self.version)
  end

  def to_simple_h
    {name: name, version: version}
  end
end

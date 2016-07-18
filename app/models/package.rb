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
    Vulnerability.where("? = ANY(package_names)", name).where(:package_platform => platform)
  end

  def same_name?(pkg_names)
    if self.platform == Platforms::Debian
      pkg_names.include?(self.source_name)
    else
      pkg_names.include?(self.name)
    end
  end

  # TODO: needs to account for fact patched and unaffected versions
  # can refer to many different packages now

  def affected?(unaffected_versions)
    unaffected_versions.any? do |v|
      !same_version?(v)
    end
  end

  def needs_patch?(patched_versions)
    patched_versions.any? do |v|
      !same_version?(v)
    end
  end

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

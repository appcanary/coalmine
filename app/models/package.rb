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
# todo: track if submitted from users?
class Package < ActiveRecord::Base
  has_many :bundled_packages
  has_many :bundles, :through => :bundled_packages
  has_many :vulnerable_packages
  has_many :vulnerabilities, :through => :vulnerable_packages
  has_many :advisories, :through => :vulnerabilities

  validates_uniqueness_of :version, scope: [:platform, :release, :name]

  scope :pluck_relevant_unique_fields, ->(platform) { 
    uniquely_id_cols = relevant_columns(platform)
    select_str = uniquely_id_cols.map(&:to_s).join(", ")

    select(select_str).pluck(*uniquely_id_cols)
  }

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

  # go over the semantics of this exactly,
  # potentially rename to not_affected?

  def not_affected?(unaffected_versions)
    unaffected_versions.any? do |v|
      version_matches?(v)
    end
  end

  def been_patched?(patched_versions)
    patched_versions.any? do |v|
      version_matches?(v)
    end
  end

  def version_matches?(other_version)
    comparator.matches?(other_version)
  end

  def comparator
    @comparator ||= Platforms.comparator_for(self.platform).new(self)
  end

  def to_simple_h
    {name: name, version: version}
  end

  # move to presenter/values object
  def to_relevant_h
    hsh = {}
    Package.relevant_columns(platform).each do |k|
      hsh[k] = self[k]
    end
    hsh
  end

  def to_relevant_values
    Package.relevant_columns(platform).map do |k|
      self[k]
    end
  end
  
  def self.to_relevant_clauses(platform)
    self.relevant_columns(platform).map { |k|
      "#{k} = ?"
    }.join("AND ")
  end

  def self.relevant_columns(platform)
    case platform
    when Platforms::CentOS
      [:name, :version, :epoch, :version_release, :arch]
    else
      [:name, :version]
    end
  end
end

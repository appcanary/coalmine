# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  platform            :string           not null
#  release             :string
#  package_name        :string           not null
#  arch                :string
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  pending             :boolean          default("false"), not null
#  end_of_life         :boolean          default("false"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#
# Indexes
#
#  index_vulnerable_dependencies_on_expired_at                 (expired_at)
#  index_vulnerable_dependencies_on_package_name               (package_name)
#  index_vulnerable_dependencies_on_platform                   (platform)
#  index_vulnerable_dependencies_on_platform_and_package_name  (platform,package_name)
#  index_vulnerable_dependencies_on_valid_at                   (valid_at)
#  index_vulnerable_dependencies_on_vulnerability_id           (vulnerability_id)
#

class VulnerableDependency < ActiveRecord::Base
  belongs_to :vulnerability
  has_many :vulnerable_packages, :dependent => :destroy

  validates :vulnerability_id, :presence => true
  validates :platform, :presence => true
  validates :package_name, :presence => true

  delegate :title, :to => :vulnerability, :prefix => true
  
  # strictly, is this a package from the same platform?
  #
  def concerns?(package)
    same_pr = (package.platform == self.platform) && 
      (package.release == self.release)

    return same_pr unless same_pr

    if self.arch.present?
      same_pr = same_pr && self.arch == package.arch
    end

    same_pr && package.same_name?(self.package_name)
  end

  # whether this package could be vulnerable

  # N_A?  B_P?  Vuln?
  # T     T     F
  # T     F     F
  # F     T     F
  # F     F     T
  #
  # i.e. !(N_A? || B_P?)

  def affects?(package)
    # a package is vulnerable if
    # it's not in the unaffected_versions AND
    # it's not been patched
    concerns?(package) && 
      !(package.not_affected?(unaffected_versions) ||
        package.been_patched?(patched_versions))
  end

  def patcheable?
    self.patched_versions.present?
  end

  # used to filter and select collections of 
  # vuln_deps within the VulnManager
  def unique_hash
    @unique_hash ||= self.attributes.except("id", "pending", "end_of_life", "created_at", "updated_at", "valid_at", "expired_at")
  end

end

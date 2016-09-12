# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  package_platform    :string           not null
#  package_name        :string           not null
#  release             :string
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
#  index_vulnerable_dependencies_on_expired_at  (expired_at)
#  index_vulnerable_dependencies_on_valid_at    (valid_at)
#

class VulnerableDependency < ActiveRecord::Base
  belongs_to :vulnerability
  has_many :vulnerable_packages, :dependent => :destroy

  validates :vulnerability_id, :presence => true
  validates :package_platform, :presence => true
  validates :package_name, :presence => true

  delegate :title, :to => :vulnerability, :prefix => true
  
  # strictly, is this a package from the same platform?
  # TODO: concerns belongs in package, BP & NA here
  def concerns?(package)
    same_pr = (package.platform == self.package_platform) && 
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

  def unique_hash
    @unique_hash ||= self.attributes.except("id", "created_at", "updated_at", "valid_at", "expired_at")
  end

end

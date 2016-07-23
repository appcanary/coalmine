# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  package_platform    :string           not null
#  package_name        :string           not null
#  affected_arches     :string           default("{}"), not null, is an Array
#  affected_releases   :string           default("{}"), not null, is an Array
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#

class VulnerableDependency < ActiveRecord::Base
  belongs_to :vulnerability

  validates :vulnerability_id, :presence => true
  validates :package_platform, :presence => true
  validates :package_name, :presence => true
  
  def concerns?(package)
    (package.platform == self.package_platform) && 
      package.same_name?(self.package_name)
  end

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
end

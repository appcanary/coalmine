# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  package_platform    :string           not null
#  package_name        :string           not null
#  affected_arches     :string
#  affected_releases   :string
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#

class VulnerableDependency < ActiveRecord::Base
  belongs_to :vulnerability
  # TODO VALIDATIONS
  
  def concerns?(package)
    (package.platform == self.package_platform) && 
      package.same_name?(self.package_name)
  end


  def affects?(package)
    (package.affected?(unaffected_versions) ||
     package.needs_patch?(patched_versions))
  end
end

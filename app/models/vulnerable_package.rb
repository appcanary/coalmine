# == Schema Information
#
# Table name: vulnerable_packages
#
#  id                       :integer          not null, primary key
#  package_id               :integer          not null
#  vulnerable_dependency_id :integer          not null
#  vulnerability_id         :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  valid_at                 :datetime         not null
#  expired_at               :datetime         default("infinity"), not null
#

class VulnerablePackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :vulnerable_dependency

  # vulnerability link is purely for bookkeeping convenience
  belongs_to :vulnerability

  has_many :bundled_packages

  def unique_hash
    @unique_hash ||= self.attributes.except("id", "created_at", "updated_at", "valid_at", "expired_at")
  end

end

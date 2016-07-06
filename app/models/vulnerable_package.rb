# == Schema Information
#
# Table name: vulnerable_packages
#
#  id               :integer          not null, primary key
#  package_id       :integer          not null
#  vulnerability_id :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
#

class VulnerablePackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :vulnerability

  has_many :bundled_packages
end

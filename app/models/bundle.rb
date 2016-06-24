# == Schema Information
#
# Table name: bundles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  path       :string
#  platform   :string
#  release    :string
#  last_crc   :integer
#  from_api   :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Bundle < ActiveRecord::Base
  belongs_to :account
  has_many :bundled_packages
  has_many :packages, :through => :bundled_packages

  def vulnerable_packages
    VulnerablePackage.where('"bundled_packages".bundle_id = ?', self.id).joins('inner join bundled_packages on "bundled_packages".package_id ="vulnerable_packages".package_id')
  end
end

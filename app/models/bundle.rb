# == Schema Information
#
# Table name: package_sets
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
  has_many :bundled_packages
  has_many :packages, :through => :packages_package_sets
end

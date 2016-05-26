# == Schema Information
#
# Table name: package_sets
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  path       :string
#  kind       :string
#  release    :string
#  last_crc   :integer
#  from_api   :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PackageSet < ActiveRecord::Base
  has_many :packages_package_sets
  has_many :packages, :through => :packages_package_sets
end

# == Schema Information
#
# Table name: pallets
#
#  id            :integer          not null, primary key
#  account_id_id :integer
#  name          :string
#  path          :string
#  kind          :string
#  release       :string
#  last_crc      :integer
#  from_api      :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Pallet < ActiveRecord::Base
  has_many :package_sets
  has_many :packages, :through => :package_sets
end

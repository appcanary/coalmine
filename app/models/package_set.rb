# == Schema Information
#
# Table name: package_sets
#
#  id            :integer          not null, primary key
#  pallet_id_id  :integer
#  package_id_id :integer
#  vulnerable    :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PackageSet < ActiveRecord::Base
  belongs_to :package
  belongs_to :pallet
end

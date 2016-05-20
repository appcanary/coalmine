class PackageSet < ActiveRecord::Base
  belongs_to :package
  belongs_to :pallet
end

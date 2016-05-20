class Pallet < ActiveRecord::Base
  has_many :packages, :through => :package_set
end

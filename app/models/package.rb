class Package < ActiveRecord::Base
  has_many :pallets, :through => :package_set

end

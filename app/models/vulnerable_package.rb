class VulnerablePackage < ActiveRecord::Base
  belongs_to :package_id
  belongs_to :vulnerability_id
end

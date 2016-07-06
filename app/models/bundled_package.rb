# == Schema Information
#
# Table name: bundled_packages
#
#  id         :integer          not null, primary key
#  bundle_id  :integer          not null
#  package_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  valid_at   :datetime         not null
#  expired_at :datetime         default("infinity"), not null
#

# TODO: enforce uniqueness constraint

class BundledPackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :bundle

  scope :select_log_join_vulns, -> { 
    select('"bundled_packages".bundle_id, 
           "bundled_packages".id bundled_package_id, 
           "bundled_packages".package_id, 
           "vulnerable_packages".id vulnerable_package_id, 
           "vulnerable_packages".vulnerability_id').
      joins('INNER JOIN "vulnerable_packages" ON
            "vulnerable_packages".package_id = "bundled_packages".package_id')
  }
end

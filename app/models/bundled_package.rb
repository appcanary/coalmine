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

  # selecting the cols needed for LBV and LBP,
  # joined on VP where the package_id matches
  scope :select_log_joins_vulns, -> { 
    select('"bundled_packages".bundle_id, 
           "bundled_packages".id bundled_package_id, 
           "bundled_packages".package_id, 
           "vulnerable_packages".id vulnerable_package_id, 
           "vulnerable_packages".vulnerable_dependency_id, 
           "vulnerable_packages".vulnerability_id,
           "bundled_packages".valid_at occurred_at').
           joins_vulns 
  }

  scope :joins_vulns, -> {
    joins('INNER JOIN "vulnerable_packages" ON
           "vulnerable_packages".package_id = "bundled_packages".package_id')

  }


  scope :where_lbv_not_already_logged, -> {
    where('NOT EXISTS 
           (SELECT 1 FROM "log_bundle_vulnerabilities" lbv 
           WHERE lbv.bundle_id = "bundled_packages".bundle_id AND 
                 lbv.package_id = "bundled_packages".package_id AND 
                 lbv.bundled_package_id = "bundled_packages".id AND 
                 lbv.vulnerability_id = "vulnerable_packages".vulnerability_id AND 
                 lbv.vulnerable_dependency_id = "vulnerable_packages".vulnerable_dependency_id AND 
                 lbv.vulnerable_package_id = "vulnerable_packages".id)')
  }



end

# == Schema Information
#
# Table name: bundled_packages
#
#  id         :integer          not null, primary key
#  bundle_id  :integer
#  package_id :integer
#  vulnerable :boolean          default("false"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BundledPackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :bundle

  scope :select_log_join_vulns, -> { 
    select('bundle_id, 
           "bundled_packages".id bundled_package_id, 
           "bundled_packages".package_id, 
           "vulnerable_packages".id vulnerable_package_id, 
           "vulnerable_packages".vulnerability_id').
      joins('INNER JOIN "vulnerable_packages" ON
            "vulnerable_packages".package_id = "bundled_packages".package_id')
  }
end

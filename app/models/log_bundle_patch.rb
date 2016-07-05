# == Schema Information
#
# Table name: log_bundle_patches
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer
#  package_id            :integer
#  bundled_package_id    :integer
#  vulnerability_id      :integer
#  vulnerable_package_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class LogBundlePatch < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :vulnerable_package

  # Every time a bundle is changed, note whether
  # the bundle is *no longer* vulnerable to a vuln
  # at that point in time.
  #
  # We create a log instances whenever:
  # 1. A bundle is updated, and is no longer vuln
  # 2. Vulnerability that affects a package in bundle gets deleted
  # 3. Vulnerability that affects a package is edited, & package no longer affected
  
  def self.record_vulnerability_change!(vuln_id)
    # something was vulnerable before, but no longer is.
    #
    # i.e. you were vulnerable at t=0
    # the bundle got updated
    # you are now no longer vuln, aka patch
    #
    # Get a list of things we've logged a vulnerability, that we haven't recorded a patch for,
    # that we are not vulnerable to at this moment
    
    # LogBundleVulnerability.joins('INNER JOIN "bundled_packages" bp ON
    #                              "log_bundle_vulnerabilities".bundle_id = bp.bundle_id AND
    #                              "log_bundle_vulnerabilities".bundled_package_id = bp.id')

    lbv = LogBundleVulnerability.unpatched_vuln_logs.where(
      'NOT EXISTS
       (SELECT 1 from "bundled_packages" bp WHERE 
         bp.bundle_id = "log_bundle_vulnerabilities".bundle_id AND
         bp.package_id = "log_bundle_vulnerabilities".package_id AND
         bp.id = "log_bundle_vulnerabilities".bundled_package_id)').
      where('"log_bundle_vulnerabilities".vulnerability_id = ?', vuln_id)
  end

  def self.record_bundle_patches!(bundle_id)
    # has not been patched
    # and does not current exist in the bundle
     lbv = LogBundleVulnerability.where(
       'NOT EXISTS 
       (SELECT 1 FROM "log_bundle_patches" lbp WHERE
         lbp.bundle_id = "log_bundle_vulnerabilities".bundle_id AND
         lbp.package_id = "log_bundle_vulnerabilities".package_id AND
         lbp.bundled_package_id = "log_bundle_vulnerabilities".bundled_package_id AND
         lbp.vulnerability_id = "log_bundle_vulnerabilities".vulnerability_id AND
         lbp.vulnerable_package_id = "log_bundle_vulnerabilities".vulnerable_package_id)').
       where('NOT EXISTS
             (SELECT 1 from "bundled_packages" bp WHERE 
               bp.bundle_id = "log_bundle_vulnerabilities".bundle_id AND
               bp.package_id = "log_bundle_vulnerabilities".package_id AND
               bp.id = "log_bundle_vulnerabilities".bundled_package_id)').
       where('"log_bundle_vulnerabilities".bundle_id = ?', bundle_id)

     lbv.each do |lbv|
       self.create(:bundle_id => lbv.bundle_id,
                   :package_id => lbv.package_id,
                   :bundled_package_id => lbv.bundled_package_id,
                   :vulnerability_id => lbv.vulnerability_id,
                   :vulnerable_package_id => lbv.vulnerable_package_id)
     end
  end

end

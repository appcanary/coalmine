# == Schema Information
#
# Table name: log_bundle_patches
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer          not null
#  package_id            :integer          not null
#  bundled_package_id    :integer          not null
#  vulnerability_id      :integer          not null
#  vulnerable_package_id :integer          not null
#  occurred_at           :datetime         not null
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
  
  # untested; waiting for VulnMger#update
  def self.record_vulnerability_change!(vuln_id)


    # a vuln has been changed. There are either new
    # packages in bundles affected by it, or there are fewer
    # packages in bundles affected by it.
    #
    # two options: 
    # 1) a vuln change has added vuln packgs
    # 2) a vuln change has removed vuln pkgs
    #
    # this is a patch log so we do not care about 1). 
    # in the event of 2), by definition we'll have removed
    # a VulnerablePackage.
    #
    # So, we need to look inside VulnerablePackageArchive.
    #
    # Will we care about BundledPackageArchive? No, because
    # those packages are in the past - they're "vulnerable" retroactively,
    # but there's no patch notification, kind of pointless info.
    #
    # "You USED to have packages that, turns out, are vulnerable!" -- 
    # not useful information.
    #
    # Therefore, this should only affect thigns in current bundles.
    # Specifically, we're only concerned with packages in current bundles
    # that used to be affected by this vuln but now aren't.

# 
#     lbv = LogBundleVulnerability.unpatched_vuln_logs.where(
#       'NOT EXISTS
#        (SELECT 1 from "bundled_packages" bp WHERE 
#          bp.bundle_id = "log_bundle_vulnerabilities".bundle_id AND
#          bp.package_id = "log_bundle_vulnerabilities".package_id AND
#          bp.id = "log_bundle_vulnerabilities".bundled_package_id)').
#       where('"log_bundle_vulnerabilities".vulnerability_id = ?', vuln_id)
  end

  def self.record_bundle_patches!(bundle_id)

    # get a list of ALL BPAs, formatted as an LBP
    # that have ever been vulnerable (i.e. there exists a VulnPkg,
    # that existed while the bundled package was present in a bundle) that
    # are not present in the list of vulnerable packages in the current
    # bundle, that have not already been logged in the LBP.
    lbv = BundledPackageArchive.select_valid_log_joins_vulns.
      where(:bundle_id => bundle_id).
      where("bundled_package_id NOT IN 
            (#{BundledPackage.select("id").joins_vulns.where(:bundle_id => bundle_id).to_sql})").
      where('NOT EXISTS
            (SELECT 1 from "log_bundle_patches" lbp WHERE 
            lbp.bundle_id = "bundled_package_archives".bundle_id AND
            lbp.package_id = "bundled_package_archives".package_id AND
            lbp.bundled_package_id = "bundled_package_archives".bundled_package_id AND
            lbp.vulnerability_id = "vulnerable_packages".vulnerability_id AND
            lbp.vulnerable_package_id = "vulnerable_packages".id AND
            lbp.occurred_at = "bundled_package_archives".expired_at)')


    lbv.each do |lbv|
     self.create(:bundle_id => lbv.bundle_id,
                 :package_id => lbv.package_id,
                 :bundled_package_id => lbv.bundled_package_id,
                 :vulnerability_id => lbv.vulnerability_id,
                 :vulnerable_package_id => lbv.vulnerable_package_id,
                 :occurred_at => lbv.occurred_at)
    end
  end
end

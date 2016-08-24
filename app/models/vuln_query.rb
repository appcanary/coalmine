# this class namespaces all the different queries we 
# run that determine whether something is vulnerable.
#
# i.e. given a bundle, give me info on what's vuln
# given a set of notifications, give me what i need
# to report on.

class VulnQuery
  def self.from_patched_notifications(notifications) 
    LogBundlePatch.where("id in (#{notifications.select("log_bundle_patch_id").to_sql})").includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_vuln_notifications(notifications)
    LogBundleVulnerability.where("id in (#{notifications.select("log_bundle_vulnerability_id").to_sql})").includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_bundle(bundle)
    bundle.packages.joins(:vulnerable_packages).distinct("packages.id").includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.from_packages(package_query)
    package_query.joins(:vulnerable_packages).distinct("packages.id").includes(:vulnerabilities, :vulnerable_dependencies)
  end
end

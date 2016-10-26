# this class namespaces all the different queries we 
# run that determine whether something is vulnerable.
#
# i.e. given a bundle, give me info on what's vuln
# given a set of notifications, give me what i need
# to report on.

class VulnQuery
  attr_reader :account
  def initialize(account)
    @account = account
  end

  def from_bundle(bundle)
    if account.notify_everything?
      self.class.from_bundle(bundle)
    else
      self.class.patcheable_from_bundle(bundle)
    end
  end

  def vuln_server?(server)
    if account.notify_everything?
      server.bundles.any?(&:vulnerable_at_all?)
    else
      server.bundles.any? { |b|
        b.vulnerable? == :patcheable
      }
    end
  end

  def self.from_notifications(notifications, type)
    case type
    when :vuln
      from_vuln_notifications(notifications)
    when :patched
      from_patched_notifications(notifications)
    end
  end

  def self.from_patched_notifications(notifications) 
    LogBundlePatch.where("id in (#{notifications.select("log_bundle_patch_id").to_sql})").includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_vuln_notifications(notifications)
    LogBundleVulnerability.where("id in (#{notifications.select("log_bundle_vulnerability_id").to_sql})").includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_bundle(bundle)
    bundle.affected_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.patcheable_from_bundle(bundle)
    bundle.patcheable_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.from_packages(package_query)
    package_query.joins(:vulnerable_packages).distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end
end

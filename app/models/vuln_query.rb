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
      self.class.patchable_from_bundle(bundle)
    end
  end

  def vuln_server?(server)
    if account.notify_everything?
      server.vulnerable?
    else
      server.patchable?
    end
  end

  def vuln_bundle?(bundle)
    if account.notify_everything?
      bundle.vulnerable?
    else
      bundle.patchable?
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

  def self.from_patched_notifications(notification_rel)
    LogBundlePatch.joins(:notifications).merge(notification_rel).includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_vuln_notifications(notification_rel)
    LogBundleVulnerability.joins(:notifications).merge(notification_rel).includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_bundle(bundle)
    bundle.affected_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.patchable_from_bundle(bundle)
    bundle.patchable_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.from_packages(package_query)
    package_query.joins(:vulnerable_packages).distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end
end

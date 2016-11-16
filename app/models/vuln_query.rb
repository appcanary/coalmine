# This class should be sole entry point in entire system
# for determining if something is "vulnerable"
#
# It can be called directly via class methods, or when 
# instantiated with an account object it will conform to user's
# expectations of what they care about.
#
# TODO: it assumes permissions check has been performed elsewhere
# is that a good idea or should we check as well?


class VulnQuery
  attr_reader :account
  def initialize(account)
    @account = account
  end

  def from_bundle(bundle)
    if care_about_affected?
      self.class.affected_from_bundle(bundle)
    else
      self.class.patchable_from_bundle(bundle)
    end
  end

  def vuln_server?(server)
    if care_about_affected?
      server.vulnerable?
    else
      server.patchable?
    end
  end

  def vuln_bundle?(bundle)
    if care_about_affected?
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

  def care_about_affected?
    account.notify_everything?
  end

  def self.from_patched_notifications(notification_rel)
    LogBundlePatch.joins(:notifications).merge(notification_rel).includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_vuln_notifications(notification_rel)
    LogBundleVulnerability.joins(:notifications).merge(notification_rel).includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.affected_from_bundle(bundle)
    bundle.affected_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.patchable_from_bundle(bundle)
    bundle.patchable_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def self.from_packages(package_query)
    package_query.joins(:vulnerable_packages).distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end
end

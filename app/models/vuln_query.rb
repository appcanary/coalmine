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
  attr_reader :account, :query_bundle

  PROCS = {
    affected_bundle: -> (bundle) {
      bundle.affected_packages
    },
    patchable_bundle: -> (bundle) {
      bundle.patchable_packages
    },
  }

  def initialize(account)
    @account = account

    if care_about_affected?(@account)
      @query_bundle = PROCS[:affected_bundle]
    else
      @query_bundle = PROCS[:patchable_bundle]
    end
  end

  def from_bundle(bundle)
    uniq_and_include(filter_with_log(query_bundle.(bundle)))
  end

  def vuln_server?(server)
    server.bundles.any? { |b|
      vuln_bundle?(b)
    }
  end

  def vuln_bundle?(bundle)
    filter_with_log(limit_query(query_bundle.(bundle))).any?
  end

  def self.from_notifications(notifications, type)
    case type
    when :vuln
      from_vuln_notifications(notifications)
    when :patched
      from_patched_notifications(notifications)
    end
  end

  def care_about_affected?(acct)
    acct.notify_everything?
  end

  # --- fns for filtering
  def filter_with_log(pkg_query)
    pkg_query.merge(LogResolution.filter_for(account.id))
  end

  def uniq_and_include(pkg_query)
    pkg_query.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end

  def limit_query(pkg_query)
    pkg_query.limit(1).select(1)
  end


  def self.from_patched_notifications(notification_rel)
    LogBundlePatch.joins(:notifications).merge(notification_rel).includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  def self.from_vuln_notifications(notification_rel)
    LogBundleVulnerability.joins(:notifications).merge(notification_rel).includes({package: :vulnerable_dependencies}, :vulnerability, :bundle)
  end

  # TODO: convert to using methods above
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

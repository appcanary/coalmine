# This class should be sole entry point in entire system
# for determining if something is "vulnerable".
#
# When instantiated with an Account, this class figures out
# what the Account has configured "vulnerable" to mean to them,
# i.e. whether they want to know about packages w/o patches
#
# TODO: it assumes permissions check has been performed elsewhere
# is that a good idea or should we check as well?


class VulnQuery
  attr_reader :account, :query_bundle, :query_log

  PROCS = {
    affected_bundle: -> (bundle) {
      bundle.affected_packages
    },
    patchable_bundle: -> (bundle) {
      bundle.patchable_packages
    },
    affected_unnotified_logs: -> (logklass, account) {
      logklass.unnotified_logs.
      where("bundles.account_id = ?", account.id)
    },
    patchable_unnotified_logs: -> (logklass, account) {
      logklass.unnotified_logs.patchable.
      where("bundles.account_id = ?", account.id)
    }

  }

  def initialize(account)
    @account = account

    if care_about_affected?(@account)
      @query_bundle = PROCS[:affected_bundle]
      @query_log = PROCS[:affected_unnotified_logs]
    else
      @query_bundle = PROCS[:patchable_bundle]
      @query_log = PROCS[:patchable_unnotified_logs]
    end
  end

  # ---- methods that give you the info you want
  def from_bundle(bundle)
    uniq_and_include(filter_resolved(query_bundle.(bundle)))
  end

  def vuln_server?(server)
    server.bundles.any? { |b|
      vuln_bundle?(b)
    }
  end

  def vuln_bundle?(bundle)
    filter_resolved(limit_query(query_bundle.(bundle))).any?
  end

  def unnotified_vuln_logs
    filter_resolved(query_log.(LogBundleVulnerability, account))
  end

  def unnotified_patch_logs
    filter_resolved(query_log.(LogBundlePatch, account))
  end

  # --- effectively private methods

  def care_about_affected?(acct)
    acct.notify_everything?
  end

  # --- fns for filtering
  def filter_resolved(query)
    LogResolution.filter_query_for(query, account.id)
  end

  def uniq_and_include(pkg_query)
    pkg_query.distinct.preload(:vulnerable_dependencies,:vulnerabilities)
  end

  def limit_query(pkg_query)
    pkg_query.limit(1).select(1)
  end

  def self.from_notifications(notifications, type)
    case type
    when :vuln
      from_vuln_notifications(notifications)
    when :patched
      from_patched_notifications(notifications)
    end
  end


  # assumption is everything dumped into a notification
  # has already been appropriately filtered.

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

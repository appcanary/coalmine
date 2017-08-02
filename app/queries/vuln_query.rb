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
    affected_logs: -> (logklass, account) {
      log_table = logklass.table_name

      logklass.
        joins("LEFT JOIN bundled_packages ON
          bundled_packages.id = #{log_table}.bundled_package_id AND
          bundled_packages.bundle_id = #{log_table}.bundle_id").
        where("bundles.account_id = ?", account.id)
    },
    patchable_logs: -> (logklass, account) {
      log_table = logklass.table_name

      logklass.patchable.
        joins("LEFT JOIN bundled_packages ON
          bundled_packages.id = #{log_table}.bundled_package_id AND
          bundled_packages.bundle_id = #{log_table}.bundle_id").
        where("bundles.account_id = ?", account.id)
    }

  }

  def initialize(account)
    @account = account

    if care_about_affected?(@account)
      @query_bundle = PROCS[:affected_bundle]
      @query_log = PROCS[:affected_logs]
      @vuln_subquery = VulnQuery.has_affected_subquery
    else
      @query_bundle = PROCS[:patchable_bundle]
      @query_log = PROCS[:patchable_logs]
      @vuln_subquery = VulnQuery.has_patchable_subquery
    end
  end

  # --- class methods to actually do the computation ---
  def self.has_affected_subquery
    packages = VulnerablePackage.joins(:vulnerable_dependency).joins("inner join bundled_packages on bundled_packages.package_id = vulnerable_packages.package_id").where("bundled_packages.bundle_id = bundles.id")
    self.filter_ignored_relative(self.filter_resolved_relative(packages)).exists
  end

  def self.has_patchable_subquery
    packages = VulnerablePackage.joins(:vulnerable_dependency).merge(VulnerableDependency.patchable).joins("inner join bundled_packages on bundled_packages.package_id = vulnerable_packages.package_id").where("bundled_packages.bundle_id = bundles.id")
    self.filter_ignored_relative(self.filter_resolved_relative(packages)).exists
  end

  # ---- methods that give you the info you want
  def from_bundle(bundle)
    uniq_and_include(filter_ignored(filter_resolved(query_bundle.(bundle))))
  end

  def vuln_server?(server)
    server.bundles.any? { |b|
      vuln_bundle?(b)
    }
  end

  def vuln_bundle?(bundle)
    # this is a little ugly but it lets us reuse the subquery
    Bundle.where(:id => bundle.id).pluck(@vuln_subquery.to_sql).first
  end

  def vuln_hsh(bundles)
    # Given a bundle query object return a hash of Bundle id => vulnerable?
    bundles.pluck("id, (#{@vuln_subquery.to_sql}) vulnerable").to_h
  end

  def unemailed_vuln_logs
    filter_ignored(filter_resolved(query_log.(LogBundleVulnerability.unemailed, account)))
  end

  def unwebhooked_vuln_logs
    filter_ignored(filter_resolved(query_log.(LogBundleVulnerability.unwebhooked, account)))
  end

  def unemailed_patch_logs
    filter_ignored(filter_resolved(query_log.(LogBundlePatch.unemailed, account)))
  end

  def unwebhooked_patch_logs
    filter_ignored(filter_resolved(query_log.(LogBundlePatch.unwebhooked, account)))
  end

  # --- effectively private methods

  def care_about_affected?(acct)
    acct.notify_everything?
  end

  # --- fns for filtering
  def filter_resolved(query)
    LogResolution.filter_query_for(query, account.id)
  end

  def self.filter_resolved_relative(query)
    #Don't include a specific account id in the filter query, we instead get it from "bundles.account_id". This speeds up the query
    LogResolution.filter_query_for(query)
  end

  def filter_ignored(query)
    IgnoredPackage.filter_query_for(query, account.id)
  end

  def self.filter_ignored_relative(query)
    #Don't include a specific account id in the filter query, we instead get it from "bundles.account_id". This speeds up the query
    IgnoredPackage.filter_query_for(query)
  end

  def uniq_and_include(pkg_query)
    # temporary note: preloading works fine on small numbers of 
    # associations; but some packages have 150+ vulnerabilities.
    # preloading it, at least in development, seems to be causing
    # all sorts of memory management hell.
    #
    # basically we need to upend everything and cache it
    # but, ironically, making lots of queries seems to be better 
    # than preloading thousands of objects
    # pkg_query.distinct.preload(:vulnerable_dependencies,:vulnerabilities)
 
    pkg_query.distinct
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
    # like the comment above it turns out that running tons of queries is faster then including all of this
    #bundle.affected_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
    bundle.affected_packages.distinct
  end

  def self.patchable_from_bundle(bundle)
    # like the comment above it turns out that running tons of queries is faster then including all of this
    #bundle.patchable_packages.distinct.includes(:vulnerabilities, :vulnerable_dependencies)
    bundle.patchable_packages.distinct
  end

  def self.from_packages(package_query)
    package_query.joins(:vulnerable_packages).distinct.includes(:vulnerabilities, :vulnerable_dependencies)
  end
end

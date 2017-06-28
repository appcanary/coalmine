class DailySummaryQuery
  attr_accessor :account, :date, :begin_at, :end_at, :all_servers, :new_servers, :deleted_servers, :all_monitors, :new_monitors, :deleted_monitors

  def initialize(account, date)
    @account = account
    @date = date
    @begin_at = @date.beginning_of_day
    @end_at = @date.end_of_day


    # ---- we now establish some basic facts

    @all_servers = AgentServer.where(account_id: account.id)

    @new_servers = AgentServer.where(account_id: account.id).created_on(@begin_at)

    @deleted_servers = AgentServer.where(account_id: account.id).deleted_on(@begin_at)

    @all_monitors = Bundle.where(account_id: account.id).via_api

    @new_monitors = Bundle.where(account_id: account.id).created_on(@begin_at).via_api

    @deleted_monitors = Bundle.where(account_id: account.id).deleted_on(@begin_at).via_api

    # ---- and we set up the basic queries
    @log_vuln_query = LogBundleVulnerability.in_bundles_from(account.id).unpatched_as_of(@end_at)
    @log_patch_query = LogBundlePatch.in_bundles_from(account.id).not_vulnerable_as_of(@end_at)

    @lbv_unpatched_fixable = @log_vuln_query.patchable.includes(:vulnerability, :package)
    @lbv_unpatched_cantfix = @log_vuln_query.unpatchable.includes(:vulnerability, :package)

    @lbp_notvuln_fixable = @log_patch_query.patchable.includes(:vulnerability, :package)

  end

  def create_presenter
    DailySummaryPresenter.new(self)
  end

  def all_vuln_ct
    @lbv_unpatched_fixable.pluck(:vulnerability_id).uniq.size
  end

  def fresh_vulns
    # Vulnerabilities that are new for you and are patchable
    fresh_vulns = @lbv_unpatched_fixable.vulnerable_after(@begin_at)
  end

  def new_vulns
    # Vulnerabilities that are new for you but may have existed before
    new_vulns = @lbv_unpatched_fixable.where("log_bundle_vulnerabilities.created_at >= ? and log_bundle_vulnerabilities.created_at <= ?", @begin_at, @end_at).vulnerable_before(@begin_at)

    # make sure we don't report on stuff from brand new
    # or deleted servers

    new_vulns = new_vulns.where.not('bundles.agent_server_id': @new_servers.map(&:id) + @deleted_servers.map(&:id))
  end

  def patched_vulns
    net_patches = @lbp_notvuln_fixable.where("log_bundle_patches.occurred_at >= ? and log_bundle_patches.occurred_at <= ?", @begin_at, @end_at)

    # make sure we don't report on stuff from brand new
    # or deleted servers

    net_patches = net_patches.where.not('bundles.agent_server_id':  @new_servers.map(&:id) + @deleted_servers.map(&:id))
  end

  def cantfix_vulns
    @lbv_unpatched_cantfix.vulnerable_after(@begin_at)
  end

  def changes
    # We want only the bundles that had changes today.
    # We can do this by calling updated_at if it's a monitor but it's not clear if agent_servers also do a .touch when changing packages
    all_changed_bundle_ids = BundledPackage.from(BundledPackage.union_str(BundledPackage.created_on(@begin_at), BundledPackage.deleted_on(@begin_at))).pluck('distinct bundle_id')
    changed_bundles = account.bundles.where(id: all_changed_bundle_ids)
    hsh = {removed_ct: 0, added_ct: 0, upgraded_ct: 0, server_ids: {}, monitor_ids: {}}
    changes = changed_bundles.reduce(hsh) { |acc, bundle|
      bq = BundleQuery.new(bundle, @end_at)
      removed, added = bq.package_delta(@begin_at)

      hsh = Hash.new(0)
      added.each do |pkg|
        hsh[pkg.name] += 1
      end
      removed.each do |pkg|
        hsh[pkg.name] -= 1
      end


      removed_ct = hsh.select {|k,v| v == -1}.count
      added_ct = hsh.select {|k,v| v == 1}.count
      upgraded_ct = hsh.select {|k,v| v == 0}.count
      acc[:removed_ct] += removed_ct
      acc[:added_ct] += added_ct
      acc[:upgraded_ct] += upgraded_ct
      if bundle.agent_server.present?
        acc[:server_ids][bundle.agent_server_id] = 1
      else
        acc[:monitor_ids][bundle.id] = 1
      end

      acc
    }


    changes[:server_ct] = changes[:server_ids].keys.select(&:present?).count
    changes[:monitor_ct] = changes[:monitor_ids].keys.count
    changes
  end
end

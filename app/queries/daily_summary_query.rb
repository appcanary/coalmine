class DailySummaryQuery
  attr_accessor :account, :date, :begin_at, :end_at, :new_servers, :deleted_servers

  def initialize(account, date)
    @account = account
    @date = date
    @begin_at = @date.beginning_of_day
    @end_at = @date.end_of_day


    # ---- we now establish some basic facts

    @new_servers = AgentServer.where(:account_id => account.id).created_on(@begin_at)

    @deleted_servers = AgentServer.where(:account_id => account.id).deleted_on(@begin_at)

    @new_apps = Bundle.as_of(@end_at).where(:account_id => account.id).app_bundles.created_on(@begin_at)

    # ---- and we set up the basic queries
    @log_vuln_query = LogBundleVulnerability.in_bundles_from(account.id).unpatched_as_of(@end_at)
    @log_patch_query = LogBundlePatch.in_bundles_from(account.id).not_vulnerable_as_of(@end_at)
    
    @lbv_unpatched_fixable = @log_vuln_query.patchable
    @lbv_unpatched_cantfix = @log_vuln_query.unpatchable

    @lbp_notvuln_fixable = @log_patch_query.patchable

  end

  def create_presenter
    DailySummaryPresenter.new(self)
  end

  def fresh_vulns
    fresh_vulns = @lbv_unpatched_fixable.vulnerable_after(@begin_at)
  end

  def new_vulns
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
    changes = BundledPackage.revisions.joins(:bundle).where("bundles.account_id" => account.id).except(:select).select("distinct(bundle_id, bundled_packages.valid_at)::text as ds, bundle_id, agent_server_id, bundled_packages.valid_at").where("bundled_packages.valid_at <= ? and bundled_packages.valid_at >= ?", @end_at, @begin_at)
    changes = changes.where.not('bundles.agent_server_id': @new_servers.map(&:id) + @deleted_servers.map(&:id))
  end
end

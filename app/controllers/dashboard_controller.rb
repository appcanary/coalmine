class DashboardController < ApplicationController
  def index
    @vulnquery = VulnQuery.new(current_account)
    @servers = AgentServersPresenter.new(current_account, @vulnquery)
    @monitors = MonitorsPresenter.new(current_account, @vulnquery)

    wizard = OnboardWizard.new(current_user, @servers, @monitors)


    # TODO: in the future, keep track of whether ppl
    # have seen a given page before, be more intelligent
    if wizard.new_user?
      if params[:done]
        flash[:notice] = "Did you try adding a server or a monitor? We don't see it yet. Double check your settings, and refresh this page - or contact us for support: hello@appcanary.com"
      end
      redirect_to onboarding_path
      return
    end
  end

  def history

    @lbvs = current_user.account.log_bundle_vulnerabilities.includes(:vulnerability, :bundle).order("created_at DESC")
    @lbps = current_user.account.log_bundle_patches.includes(:vulnerability, :bundle).order("created_at DESC")

    @messages = current_user.account.email_messages
  end


  def summary

    account_id = current_account.id
    @account = current_account
    @date = params[:date].to_date

    @begin_at = @date.beginning_of_day
    @end_at = @date.end_of_day

    @motds = Motd.where("remove_at >= ?", @end_at)

    @vq = VulnQuery.new(@account)

    #---- 
    # The following scopes purely NEW vulns that we've NEVER seen before.
    # they will not report vulns that were added to your bundles yet whose vulns
    # do not date from this day.

    total_log_vulns = LogBundleVulnerability.in_bundles_from(account_id).unpatched_as_of(@end_at).patchable;
    total_log_patches = LogBundlePatch.in_bundles_from(account_id).not_vulnerable_as_of(@end_at).patchable;

    period_log_vulns = total_log_vulns.vulnerable_after(@begin_at)
    period_log_patches = total_log_patches.vulnerable_after(@begin_at)


    @changes = BundledPackage.revisions.joins(:bundle).where("bundles.account_id" => account_id).except(:select).select("distinct(bundle_id, bundled_packages.valid_at), bundle_id, agent_server_id, bundled_packages.valid_at").where("bundled_packages.valid_at <= ? and bundled_packages.valid_at >= ?", @end_at, @begin_at)

    @change_server_ct = @changes.map(&:agent_server_id).uniq.size
    # MUST COME AFTER LOADING ARRAY
    @change_ct = @changes.size

    # @total_vuln_pkg_ct = total_log_vulns.map(&:package_id).uniq.size
    # @total_vuln_ct = total_log_vulns.map(&:vulnerability_id).uniq.size

    @new_vulns = period_log_vulns
    @new_vulns_ct = @new_vulns.map(&:vulnerability_id).uniq.size

    @new_vuln_pkgs = @new_vulns.map(&:package_id).uniq
    @new_vuln_pkgs_ct = @new_vuln_pkgs.size

    @newly_affected_servers = @new_vulns.map(&:agent_server_id).uniq
    @newly_affected_servers_ct = @newly_affected_servers.size

    #--
=begin

    @introduced_vulns = period_log_vulns.reject(&:supplementary)
    @introduced_vulns_ct = @introduced_vulns.map(&:vulnerability_id).uniq.size


    @introduced_vuln_pkgs = @introduced_vulns.map(&:package_id).uniq
    @introduced_vuln_pkgs_ct = @introduced_vuln_pkgs.size

    @regressed_servers = @introduced_vulns.map(&:agent_server_id).uniq
    @regressed_servers_ct = @regressed_servers.size
=end


    #---- NEW THINKING HERE
    total_log_vulns.where("log_bundle_vulnerabilities.occurred_at >= ? and log_bundle_vulnerabilities.occurred_at <= ?", @begin_at, @end_at)

    total_log_patches.where("log_bundle_patches.occurred_at >= ? and log_bundle_patches.occurred_at <= ?", @begin_at, @end_at).map(&:package_id).uniq 

    #--- patches
    @new_patched_vulns = period_log_patches.map(&:vulnerability_id).uniq
    @new_patched_vulns_ct = @new_patched_vulns.size

    @new_patched_pkgs = period_log_patches.map(&:package_id).uniq
    @new_patched_pkgs_ct = @new_patched_pkgs.size

    @patched_servers = period_log_patches.map(&:agent_server_id).uniq
    @patched_servers_ct = @patched_servers.size


    @new_sorted_vulns = @new_vulns.group_by(&:vulnerability).reduce({}) { |hsh, (vuln, logs)|  hsh[vuln] = logs.uniq(&:package_id).map(&:package); hsh}.sort_by { |k, v| [-k.criticality_ordinal, -v.size] };
    # need to get:
    # what was introduced today (packages)
    # list of affected servers 
    # high medium low vulns
    #
    #
    # so lets think this thru.
    # i want every package that became vulnerable in this
    # time period.

    # Today, January 31st 2017, you became vulnerable to 10 new vulnerabilities. They affect 5 packages present in 32 servers.
    # At the same time, 3 packages affected by 8 new vulnerabilities were patched.
    #
    # followed by a table of unpatched vulns
    # a table of packages to vulns
    # a table of patched stuff

    # basic stats
    # REMINDER: these are not filtered to just patchable!

    @new_servers = AgentServer.as_of(@end_at).where(:account_id => account_id).created_on(@begin_at)

    @deleted_servers = AgentServer.as_of(@end_at).where(:account_id => account_id).deleted_on(@begin_at)
    @new_apps = Bundle.as_of(@end_at).where(:account_id => account_id).app_bundles.created_on(@begin_at)

    binding.pry

  end


  def whatever_old_code
    if false 
      vuln_logs = LogBundleVulnerability.select_bundles_and_vulns.in_bundles_from(account_id).that_are_unpatched.vulnerable_between(@begin_at, @end_at)
      patch_logs = LogBundlePatch.select_bundles_and_vulns.in_bundles_from(account_id).that_are_not_vulnerable.patched_between(@begin_at, @end_at)

      basic_stats = vuln_logs.reduce({}) { |acc, lbv| 
        acc[:vuln] ||= {}
        acc[:pkg] ||= {}
        acc[:srv] ||= {}
        acc[:vuln][lbv.vulnerability_id] = true
        acc[:pkg][lbv.package_id] = true
        acc[:srv][lbv.agent_server_id] = true unless lbv.agent_server_id.nil?
        acc 
      }

      @vuln_ct = basic_stats[:vuln].count
      @pkg_ct = basic_stats[:pkg].count
      @srv_ct = basic_stats[:srv].count


      @vulns = Vulnerability.where("id in (?)", basic_stats[:vuln].keys)
      @pkgs = Package.where("id in (?)", basic_stats[:pkg].keys)

      @pkg_by_platform = @pkgs.group_by(&:platform)
    end

  end
end

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


   
    @fresh_vulns = period_log_vulns
    @fresh_vulns_ct = @fresh_vulns.map(&:vulnerability_id).uniq.size

    @fresh_vuln_pkgs = @fresh_vulns.map(&:package_id).uniq
    @fresh_vuln_pkgs_ct = @fresh_vuln_pkgs.size

    @freshly_affected_servers = @fresh_vulns.map(&:agent_server_id).uniq
    @freshly_affected_servers_ct = @freshly_affected_servers.size

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
    # - vulnerabilities added 
    @new_servers = AgentServer.as_of(@end_at).where(:account_id => account_id).created_on(@begin_at)
    @deleted_servers = AgentServer.as_of(@end_at).where(:account_id => account_id).deleted_on(@begin_at)
    @new_apps = Bundle.as_of(@end_at).where(:account_id => account_id).app_bundles.created_on(@begin_at)


    # VULNS that happened on this day, for vulns that were reported on previous days
    # for servers that already existed before, or were not deleted.
    @new_vulns = total_log_vulns.where("log_bundle_vulnerabilities.created_at >= ? and log_bundle_vulnerabilities.created_at <= ?", @begin_at, @end_at).vulnerable_before(@begin_at)
    @new_vulns = @new_vulns.where.not('bundles.agent_server_id': @new_servers.map(&:id) + @deleted_servers.map(&:id))

    @new_vulns_ct = @new_vulns.map(&:vulnerability_id).uniq.size

    @new_vuln_pkgs = @new_vulns.map(&:package_id).uniq
    @new_vuln_pkgs_ct = @new_vuln_pkgs.size

    @new_affected_servers = @new_vulns.map(&:agent_server_id).uniq
    @new_affected_servers_ct = @new_affected_servers.size


    @new_added_vulns = @new_vulns.reject(&:supplementary)
    @new_supplmenetary_vulns = @new_vulns.select(&:supplementary)
    @new_supplmenetary_vulns_ct = @new_supplmenetary_vulns.map(&:vulnerability_id).uniq.size

    # all patches, except for deleted servers
    # todo: distinguish supplementary?

    @net_patches = total_log_patches.where("log_bundle_patches.occurred_at >= ? and log_bundle_patches.occurred_at <= ?", @begin_at, @end_at)
    @net_patches = @net_patches.where.not('bundles.agent_server_id':  @new_servers.map(&:id) + @deleted_servers.map(&:id)) 

    @net_patched_vulns = @net_patches.map(&:vulnerability_id).uniq
    @net_patched_vulns_ct = @net_patched_vulns.size

    @net_patched_pkgs = @net_patches.map(&:package_id).uniq
    @net_patched_pkgs_ct = @net_patched_pkgs.size

    @patched_servers = @net_patches.map(&:agent_server_id).uniq
    @patched_servers_ct = @patched_servers.size 

    @net_supplementary_vuln_ct = @net_patches.select(&:supplementary).map(&:vulnerability_id).uniq.size

    # all changes, except for those on new and deleted servers
    
    @changes = BundledPackage.revisions.joins(:bundle).where("bundles.account_id" => account_id).except(:select).select("distinct(bundle_id, bundled_packages.valid_at), bundle_id, agent_server_id, bundled_packages.valid_at").where("bundled_packages.valid_at <= ? and bundled_packages.valid_at >= ?", @end_at, @begin_at)
    @changes = @changes.where.not('bundles.agent_server_id': @new_servers.map(&:id) + @deleted_servers.map(&:id))

    @change_server_ct = @changes.map(&:agent_server_id).uniq.size
    # MUST COME AFTER LOADING ARRAY
    @change_pkg_ct = @changes.map do |ch| BundleQuery.new(ch.bundle, ch.valid_at).bundled_packages.where(:valid_at => ch.valid_at) end.flatten.size

    @fresh_sorted_vulns = @fresh_vulns.group_by(&:vulnerability).reduce({}) { |hsh, (vuln, logs)|  hsh[vuln] = logs.uniq(&:package_id).map(&:package); hsh}.sort_by { |k, v| [-k.criticality_ordinal, -v.size] };

    @new_sorted_vulns = @new_vulns.group_by(&:vulnerability).reduce({}) { |hsh, (vuln, logs)|  hsh[vuln] = logs.uniq(&:package_id).map(&:package); hsh}.sort_by { |k, v| [-k.criticality_ordinal, -v.size] };
    
    @sorted_net_patched_vulns = @net_patches.group_by(&:vulnerability).reduce({}) { |hsh, (vuln, logs)|  hsh[vuln] = logs.uniq(&:package_id).map(&:package); hsh}.sort_by { |k, v| [-k.criticality_ordinal, -v.size] };
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

   
    # binding.pry

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

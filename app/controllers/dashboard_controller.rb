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
    @date = params[:date].to_date

    @motds = Motd.where("remove_at >= ?", @date)
    @presenter = DailySummaryManager.new(current_account, @date).create_presenter
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

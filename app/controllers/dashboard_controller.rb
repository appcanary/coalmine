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

  def vulns
    @vulnquery = VulnQuery.new(current_account)
    @vuln_packages = @vulnquery.from_account.sort_by { |p| [-p.upgrade_priority_ordinal, p.name]}
    @account = current_account
  end

  def report
    send_data *MasterReporter.new(current_account).to_csv
  end

  def history

    @lbvs = current_user.account.log_bundle_vulnerabilities.includes(:vulnerability, :bundle).order("created_at DESC")
    @lbps = current_user.account.log_bundle_patches.includes(:vulnerability, :bundle).order("created_at DESC")

    @messages = current_user.account.email_messages
  end


  def summary
    @date = params[:date].to_date
    @account = current_account

    @motds = Motd.where("remove_at >= ?", @date)
    @presenter = DailySummaryQuery.new(current_account, @date).create_presenter
  end

end

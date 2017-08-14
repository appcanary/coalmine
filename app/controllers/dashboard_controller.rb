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
    @account = current_account
    @vulnquery = VulnQuery.new(current_account)

    @THREATS = @vulnquery.NUTHREATS
    @total_count = @THREATS.except(:select).count

    search = params.dig(:search, :value)
    if search.present?
      @THREATS = @THREATS.search_with_tags(search) 
    end
    @filtered_count = @total_count

    offset = params[:start].to_i || 0
    limit = params[:length].to_i <= 100 ? params[:length].to_i : 100

    case params.dig(:order, "0", :column)
    when "0"
      order = "vuln_title"
    when "1"
      order = "criticality"
    when "2"
      order = "tags"
    when "3"
      order = "occurred_at"
    else
      order = "criticality"
    end

    case params.dig(:order, "0", :dir)
    when "asc"
      direction = "asc nulls first"
    when "desc"
      direction = "desc nulls last"
    else
      direction = "desc nulls last"
    end

    @THREATS = @THREATS.order("#{order} #{direction}").offset(offset).limit(limit)
        
    respond_to do |format|
      format.html # the HTML view just renders the template, all the work is done in the json responder
      format.json { render json: VulnsDashboardDataTablesSerializer.new(@THREATS, total_count: @total_count, filtered_count: @filtered_count, draw: params[:draw], scope: view_context).to_json }
    end
    
  end
  
  def patches
    @vulnquery = VulnQuery.new(current_account)
    @PATCHED = @vulnquery.PATCHED
  end
  
  def report
    send_data *MasterReporter.new(current_account).to_csv
  end
  
  def history
    
    @lbvs = current_user.account.log_bundle_vulnerabilities.includes(:vulnerability, :bundle).order("created_at DESC")
    @lbps = current_user.account.log_bundle_patches.includes(:vulnerability, :bundle).order("created_at DESC")
    
    @messages = current_user.account.email_messages
  end
end

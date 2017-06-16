class VulnsController < ApplicationController
  skip_before_filter :require_login

  def index
    @vulns = Vulnerability.includes(:vulnerable_dependencies)
    if params[:platform].present? && Platforms.all_platforms.include?(params[:platform])
      @platform = params[:platform]
      @vulns = @vulns.where(platform: @platform)
    end

    # TODO: next time this gets touched,
    # convert into a manager and test it tout de suite
    total_count = @vulns.count

    search = params.dig(:search, :value)
    if search.present?
      puts search
      @vulns = @vulns.search(search) 
    end
    filtered_count = @vulns.count

    offset = params[:start].to_i || 0
    limit = params[:length].to_i <= 100 ? params[:length].to_i : 100
    @vulns = @vulns.offset(offset).limit(limit)

    case params.dig(:order, "0", :column)
    when "0"
      order = "platform"
    when "1"
      order = "criticality"
    when "2"
      order = "title"
    when "5"
      order = "reported_at"
    else
      order = "reported_at"
    end

    case params.dig(:order, "0", :dir)
    when "asc"
      direction = "asc nulls first"
    when "desc"
      direction = "desc nulls last"
    else
      direction = "desc nulls last"
    end
   
    if order != "reported_at"
      # order by reported at second
      @vulns =  @vulns.order("#{order} #{direction}, reported_at desc nulls last")
    else
      @vulns = @vulns.order("#{order} #{direction}")
    end

    respond_to do |format|
      format.html # the HTML view just renders the template, all the work is done in the json responder
      format.json { render json: VulnerabilitiesDataTablesSerializer.new(@vulns, total_count: total_count, filtered_count: filtered_count, draw: params[:draw], scope: view_context).to_json }
    end


  end

  def archive
    @vulnmodel = VulnerabilityArchive.find(params[:id])
    @vuln = VulnPresenter.new(@vulnmodel, true)

    @bundles = []

    render :show
  end

  def show
    @vulnmodel = Vulnerability.find(params[:id])
    @vuln = VulnPresenter.new(@vulnmodel)

    if current_user
      @bundled_packages = BundledPackage.affected_by_vuln(current_user.account_id, @vulnmodel.id)
      @bundles = @bundled_packages.group_by(&:bundle)
    end

  end
end


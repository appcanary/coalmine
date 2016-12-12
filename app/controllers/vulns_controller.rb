class VulnsController < ApplicationController
  skip_before_filter :require_login
  def index
    @vulns = Vulnerability.paginate(:page => params[:page])

    # filter by platform
    if params[:platform].present? && Platforms.all_platforms.include?(params[:platform])
      @platform = params[:platform]
      @vulns = @vulns.where(platform: @platform)
    end

    # searching
    if params[:search].present?
      @vulns = @vulns.search(params[:search]).order(criticality: :desc, reported_at: :desc)
    else
      #if we're not searching, order by reported_at only
      @vulns = @vulns.order(criticality: :desc)
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


  private
  def set_layout
    if current_user
      "default"
    else
      "launchrock"
    end

  end
end


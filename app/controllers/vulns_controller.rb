class VulnsController < ApplicationController
  skip_before_filter :require_login
  def index
    case params[:sort_by]
    when "criticality"
      order = {criticality: :desc, reported_at: :desc}
    when "title"
      order = {title: :desc, reported_at: :desc}
    when "reported_at"
      order = {reported_at: :desc}
    else
      order = {reported_at: :desc}
    end


    @vulns = Vulnerability.order(order).paginate(:page => params[:page])

    # filter by platform
    if params[:platform].present? && Platforms.all_platforms.include?(params[:platform])
      @platform = params[:platform]
      @vulns = @vulns.where(platform: @platform)
    end

    # searching
    if params[:search].present?
      @vulns = @vulns.search(params[:search])
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


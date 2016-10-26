class VulnsController < ApplicationController
  skip_before_filter :require_login
  
  def index
    if params[:search].present?
      search = Vulnerability.search do
        fulltext params[:search] do
          highlight :description
          highlight :package_names
        end
        paginate :page => params[:page]
        if params[:platform] && params[:platform] != "all"
          with :platform, params[:platform]
        end
      end
      @vulns = search.results
      @hits = search.hits
    elsif params[:platform].present?
      @vulns = Vulnerability.where(:platform => params[:platform]).paginate(:page => params[:page]).order("updated_at desc")
    else
      @vulns = Vulnerability.paginate(:page => params[:page]).order("updated_at desc")
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

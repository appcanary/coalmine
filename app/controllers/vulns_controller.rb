class VulnsController < ApplicationController
  skip_before_filter :require_login
  def index
    redirect_to :root
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

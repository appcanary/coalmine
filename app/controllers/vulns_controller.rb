class VulnsController < ApplicationController
  skip_before_filter :require_login
  def index
    @vulns = Vulnerability.all
  end

  def show
    @vulnmodel = Vulnerability.find(params[:id])
    @vuln = VulnPresenter.new(@vulnmodel)
  end
end

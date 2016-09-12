class VulnsController < ApplicationController
  skip_before_filter :require_login
  def index
    @vulns = Vulnerability.all
  end
  def show
    @vuln = Vulnerability.find(params[:id])
  end
end

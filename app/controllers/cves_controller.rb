class CvesController < ApplicationController
  skip_before_filter :require_login

  def index
    @cves = Advisory.from_cve.all
  end

  def show
    @cve = Advisory.from_cve.find_by!(:identifier => params[:cve_id])
    @vulns = Vulnerability.by_cve_id(params[:cve_id])
  end
end

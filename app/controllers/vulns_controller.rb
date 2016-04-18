class VulnsController < ApplicationController
  skip_before_filter :require_login
  def show
    @vuln = Vulnerability.find(params[:id])
  end
end

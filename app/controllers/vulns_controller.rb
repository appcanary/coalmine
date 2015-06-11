class VulnsController < ApplicationController
  def show
    @vuln = Vulnerability.find(params[:id])
  end
end

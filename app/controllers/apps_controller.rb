class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @server = current_user.agent_servers.find(params[:server_id])
    @bundle = current_user.bundles.where(:agent_server_id => params[:server_id]).find(params[:id])

    @packages = @bundle.packages.order(:name)
    @vuln_packages = VulnQuery.new(current_account).from_bundle(@bundle)
  end
end

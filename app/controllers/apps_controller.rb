class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @server = current_user.agent_servers.find(params[:server_id])
    b = current_user.bundles.where(:agent_server_id => params[:server_id]).find(params[:id])
    @bundle = BundlePresenter.new(VulnQuery.new(current_account), b)

    @packages = @bundle.packages.order(:name)
  end
end

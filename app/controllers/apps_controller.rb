class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @server = current_user.agent_servers.find(params[:server_id])
    @app = current_user.bundles.where(:agent_server_id => params[:server_id]).find(params[:id])

    @artifacts = @app.packages
    @vuln_artifacts = PackageReport.from_bundle(@app)
  end
end

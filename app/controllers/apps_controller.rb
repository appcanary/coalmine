class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @server = current_user.server(params[:server_id])
    @app = @server.app(params[:id])
    @artifacts = @app.artifact_versions
    @vuln_artifacts = @app.vulnerable_artifact_versions
  end
end

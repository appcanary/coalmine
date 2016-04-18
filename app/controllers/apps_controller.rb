class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @server = Server.find(current_user, params[:server_id])
    @app = App.find(current_user, params[:server_id], params[:id])

    @artifacts = @app.artifact_versions
    @vuln_artifacts = @app.vulnerable_artifact_versions
  end
end

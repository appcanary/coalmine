class AppsController < ApplicationController
  def index
    respond_to do |format|
      format.json { render :json => App.fake_apps }
    end
  end

  def new
  end

  def show

    @server = current_user.server(params[:server_id])
    @app = @server.app(params[:id])
    @artifacts = @app.artifact_versions
    @vuln_artifacts = @artifacts.select { |a| a.vulnerability.present? }
  end
end

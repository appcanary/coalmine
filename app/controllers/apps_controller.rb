class AppsController < ApplicationController
  def index
    respond_to do |format|
      format.json { render :json => App.fake_apps }
    end
  end

  def new
  end

  def show
    @app = App.new
    @server = Server.new
    @vuln_artifacts = rand(3..11).times.map { Artifact.new(:vulnerable => true) }
    @artifacts = rand(16..50).times.map { Artifact.new }
  end
end

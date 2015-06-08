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
  end
end

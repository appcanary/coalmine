class ServersController < ApplicationController
  def index
    respond_to do |format|
      format.json { render :json => Server.fake_servers }
    end

  end

  def new
  end

  def show
  end
end

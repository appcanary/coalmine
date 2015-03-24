class ServersController < ApplicationController
  def index
    respond_to do |format|
      format.json { render :json => [Server.new(:name => "droplet37a")] }
    end

  end

  def new
  end

  def show
  end
end

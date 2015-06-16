class ServersController < ApplicationController
  def index
  end

  def new
  end

  def show
    @server = current_user.server(params[:id])
  end
end

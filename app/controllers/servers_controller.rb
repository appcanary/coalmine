class ServersController < ApplicationController
  def new
    @agent_token = current_user.agent_token
  end

  def show
    @server = current_user.server(params[:id])
  end
end

class DashboardController < ApplicationController
  def index
    @servers = current_user.servers
    render :index
  end
end

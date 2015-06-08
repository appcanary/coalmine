class DashboardController < ApplicationController
  def index
    @events = []
    @onboarded = params[:new_app]
    if params[:new_app]
      @events << Event.new(:kind => :new_app)
    else
      @skipnav = true
    end

    @servers = 8.times.map { Server.new }
    render :index
  end
end

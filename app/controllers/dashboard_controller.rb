class DashboardController < ApplicationController
  def index
    @events = []
    @onboarded = params[:new_app]
    if params[:new_app]
      @events << Event.new(:kind => :new_app)
    end
  end
end

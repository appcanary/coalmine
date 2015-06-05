class DashboardController < ApplicationController
  skip_before_filter :require_login
  def index
    @events = []
    @onboarded = params[:new_app]
    if params[:new_app]
      @events << Event.new(:kind => :new_app)
    else
      @skipnav = true
    end
    render :index
  end
end

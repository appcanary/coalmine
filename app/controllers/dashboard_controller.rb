class DashboardController < ApplicationController
  def index
    @events = 5.times.map { Event.new }
  end
end

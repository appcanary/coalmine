class TimelineController < ApplicationController
  def index
    @items = Timeline.for(current_user)
    respond_to do |format|
      format.json { render json: @items }
    end
  end
end

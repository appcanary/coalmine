class AppsController < ApplicationController
  def index
  end

  def show
    @app = App.new
  end
end

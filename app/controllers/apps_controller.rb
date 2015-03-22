class AppsController < ApplicationController
  def index
  end

  def new
  end

  def show
    @app = App.new
  end
end

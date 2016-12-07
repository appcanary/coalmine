class RubysecController < ApplicationController
  skip_before_filter :require_login
  before_action -> { @skiptopbar = true }

  def new
  end
end

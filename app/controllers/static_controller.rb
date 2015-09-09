class StaticController < ApplicationController
  skip_before_filter :require_login
  layout "launchrock"

  def privacy
  end
end

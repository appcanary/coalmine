class WelcomeController < ApplicationController
  skip_before_filter :require_login
  layout "launchrock"

  def index
  end

  def beta_list
    BetaUser.create email: params[:email]
    flash[:subscribed] = "Yay! We'll give you a shout once we're ready."

    redirect_to root_path
  end
end

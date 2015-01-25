class WelcomeController < ApplicationController
  def index
  end

  def beta_list
    BetaUser.create email: params[:email]
    flash[:subscribed] = "Yay! We'll give you a shout once we're ready."

    redirect_to root_path
  end
end

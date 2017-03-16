class WelcomeController < ApplicationController
  skip_before_filter :require_login
  before_filter :skip_if_logged_in, :except => :pricing
  layout "launchrock"

  def index
    @user = User.new
    @preuser = PreUser.new
    # @artifacts_count = Backend.artifacts_count
    @vulnerabilities_count = Vulnerability.count
  end

  def pricing
    @user = current_user ? current_user : User.new
    @preuser = PreUser.new
    @vulnerabilities_count = Vulnerability.count
    render 'index'
  end

  def beta_list
    BetaUser.create email: params[:email]
    flash[:subscribed] = "Yay! We'll give you a shout once we're ready."

    redirect_to root_path
  end
end

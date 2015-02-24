class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  before_filter :skip_if_logged_in, :except => :destroy
  
  def new
    @user = User.new
  end

  def create
    user_params = params[:user] || {}
    if @user = login(user_params[:email], user_params[:password])
      redirect_back_or_to(dashboard_path, notice: 'Login successful')
    else
      @user = User.new
      flash.now[:alert] = 'Login failed'
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to(:root, notice: 'Thanks. Have a good one.')
  end
end

class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  before_filter :skip_if_logged_in, :except => :destroy

  def new
    @user = User.new
  end

  def create
    user_params = params[:user] || {}
    @user = FactoryGirl.create(:user)
    
    respond_to do |format|
      if @user = login(@user.email, "somevaluehere")
        format.html { redirect_back_or_to(dashboard_path, notice: 'Login successful') }
        format.json { render json: @user, status: :created, location: dashboard_path }
      else
        format.html { 
          @user = User.new
          flash.now[:alert] = 'Login failed'
          render action: 'new'
        }

        format.json { render json: {full_messages: ["Invalid email or password."], attributes: {} }, status: :unauthorized }
      end
    end
  end

  def destroy
    logout
    redirect_to(:root, notice: 'Thanks. Have a good one.')
  end
end

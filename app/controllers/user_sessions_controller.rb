class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  before_filter :skip_if_logged_in, :except => :destroy

  before_filter -> { @skip_flash = true }
  layout 'launchrock'

  def new
    @user = User.new
  end

  def create
    user_params = params[:user] || {}
        
    respond_to do |format|
      if @user = login(user_params[:email], user_params[:password])
        Analytics.track({
          user_id: @user.datomic_id,
          event: 'Logged In'
        })

        format.html { redirect_back_or_to(dashboard_path, notice: 'Login successful') }
        format.json { render json: @user, status: :created, location: dashboard_path }
      else
        format.html { 
          @user = User.new
          @user.errors.add :base, "Invalid email or password"
          render action: 'new'
        }

        format.json { render json: {full_messages: ["Invalid email or password."], attributes: {} }, status: :unauthorized }
      end
    end
  end

  def destroy
    Analytics.track({
      user_id: current_user.datomic_id,
      event: 'Logged Out'
    })
    logout
    flash.now[:notice] = 'Thanks. Have a good one.'
    redirect_to(:root)
  end
end

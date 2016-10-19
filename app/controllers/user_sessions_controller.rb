class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  before_filter :skip_if_logged_in, :except => :destroy

  layout 'launchrock'

  def new
    @user = User.new
  end

  def create
    user_params = params[:user] || {}

    if params[:password_reset] == "true"
      send_password_reset!(user_params[:email])
      return
    end

        
    respond_to do |format|
      if @user = login(user_params[:email], user_params[:password])
        $analytics.logged_in(@user)
       
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
    $analytics.logged_out(current_user)

    logout
    flash.now[:notice] = 'Thanks. Have a good one.'
    redirect_to(:root)
  end

  def send_password_reset!(email)
    @user = User.find_by_email(email)
    if @user
      if @user.deliver_reset_password_instructions!
        msg = "We've sent a reset to your email!"
      else
        msg = "Seems like we already sent a reset. Check your spam folder?"
      end
    else
      msg = "Sorry, couldn't find that email."
    end
    redirect_to login_path, :notice => msg
  end

end

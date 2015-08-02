class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create, :pre_sign_up]
  before_filter :skip_if_logged_in, :only => [:new, :create]
  
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  layout 'launchrock'

  def stop_impersonating
    stop_impersonating_user
    redirect_to admin_root_path, notice: "Welcome back."
  end

  def pre_sign_up
    @preuser = PreUser.create(preuser_params)
    session[:pre_user_email] = @preuser.email
    redirect_to sign_up_path
  end

  # GET /users/new
  def new

    @user = User.new
    if email = session.delete(:pre_user_email)
      @user.email = email
    end

    if request.path =~ /hn/
      params[:source] = "hn"
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if UserManager.sign_up(@user)
        auto_login(@user)
        format.html { redirect_to dashboard_path }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: { attributes: @user.errors, full_messages: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # def update
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #       format.json { render json: @user, status: :ok, location: @user }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: { attributes: @user.errors, full_messages: @user.errors.full_messages }, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /users/1
  # DELETE /users/1.json
  
  def destroy
    redirect_to dashboard_path
    # @user.destroy
    # respond_to do |format|
    #   format.html { redirect_to root_path, notice: 'User was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :onboarded, :beta_signup_source)
    end

    def preuser_params
      params.require(:pre_user).permit(:email)
    end
end

class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :impersonate]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def impersonate
    impersonate_user(@user)
    redirect_to dashboard_path, notice: "You are now #{@user.email}. Be careful!"
  end

  def show
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if UserCreator.sign_up(@user)
        format.html { redirect_to admin_root_path }
        # format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render :new }
        # format.json { render json: { attributes: @user.errors, full_messages: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_users_path, notice: 'User was successfully updated.' }
        # format.json { render json: @user, status: :ok, location: @user }
      else
        format.html { render :edit }
        # format.json { render json: { attributes: @user.errors, full_messages: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :onboarded)
  end

end

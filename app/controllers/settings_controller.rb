class SettingsController < ApplicationController
  def show
    @show_stripe = true
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if UserManager.update(@user, user_params)
        format.html { redirect_to dashboard_path, notice: 'User settings updated!' }
      else
        format.html { render :show }
      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :onboarded, :newsletter_consent)
  end
end

class SettingsController < ApplicationController
  def show
    @show_stripe = true
    @user = current_user
    @agent_token = @user.agent_token
    @billing_view = BillingManager.new(@user).to_view
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
    params.require(:user).permit(:email, :password, :password_confirmation, :onboarded, :newsletter_email_consent, :daily_email_consent, :marketing_email_consent)
  end
end

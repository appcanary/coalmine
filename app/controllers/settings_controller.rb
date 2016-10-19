class SettingsController < ApplicationController
  before_action :set_vars
  def show
  end

  def update
    respond_to do |format|
      if UserManager.update(@user, user_params)
        $analytics.identify_user(@user)
        
        format.html { redirect_to dashboard_path, notice: 'User settings updated!' }
      else
        format.html { render :show }
      end
    end
  end

  def set_vars
    @show_stripe = true
    @user = current_user
    @agent_token = @user.token
    @billing_manager = BillingManager.new(@user)
    @billing_presenter = @billing_manager.to_presenter

    servers = AgentServer.belonging_to(current_user)
    @servers_count = servers.count
    @active_servers_count = servers.reject(&:gone_silent?).count
    @monitors_count = Bundle.belonging_to(current_user).via_api.count
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :onboarded, :newsletter_email_consent, :daily_email_consent, :marketing_email_consent)
  end
end

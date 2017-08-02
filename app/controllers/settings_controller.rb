class SettingsController < ApplicationController
  before_action :set_vars
  def show
    @webhook_form = WebhookForm.new(@user.account.webhook || Webhook.new)
  end

  def update
    respond_to do |format|
      if UserManager.update(@user, user_params)
        $analytics.identify_user(@user)

        format.html { redirect_to settings_path, notice: 'User settings updated!' }
      else
        format.html { render :show }
      end
    end
  end

  def webhook
    @webhook = @user.account.webhook || @user.account.build_webhook
    @webhook_form = WebhookForm.new(@webhook)
    respond_to do |format|
      if @webhook_form.validate(params[:webhook])
        @webhook.url = @webhook_form.url

        @webhook.save
        format.html { redirect_to settings_path, notice: 'User settings updated!' }
      else
        format.html { render :show }
      end
    end
  end

  def delete_webhook
    respond_to do |format|
      if @user.account.webhook.present?
        @user.account.webhook.destroy
        format.html { redirect_to settings_path, notice: 'Webhook deleted!' }
      else
        format.html { redirect_to settings_path, notice: "No webhook to delete"}
      end
    end
  end

  def reset_token
    current_user.account.regenerate_token

    if current_user.save
      notice = "Your token has been reset. Don't forget to change it everywhere!"
    else
      notice = "Something went wrong, and we were unable to save your request"
    end

    redirect_to settings_path, notice: notice
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
    params.require(:user).permit(:email, :name, :phone_number, :password, :password_confirmation, :onboarded, :newsletter_email_consent, :daily_email_consent, :marketing_email_consent, :regenerate_token, :pref_email_frequency, :purge_inactive_servers, webhook: [:url])
  end
end

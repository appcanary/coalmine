class BillingController < ApplicationController
  before_action :set_vars
  def show
  end

  def update
    notice = "You've successfully changed your billing settings. Thanks!" 

    if params[:user]
      sub_plan = params[:user][:subscription_plan]

      if @billing_manager.cancel_subscription?(sub_plan)
        @user = @billing_manager.cancel_subscription!
        notice = "You've successfully canceled your subscription. Sorry to see you go!" 

        $analytics.canceled_subscription(@user)
        SystemMailer.canceled_subscription_email(@user.id).deliver_later!

      elsif (sub = @billing_manager.valid_subscription?(sub_plan))
        if stripe_params[:stripe_token].blank?
          @user = @billing_manager.change_subscription!(sub)
          SystemMailer.subscription_plan_changed(@user.id, sub).deliver!
        else
          @user = @billing_manager.add_customer(stripe_params[:stripe_token], sub)

          # if these are stripe errors, the validation
          # on user.save below will trigger them to
          # show up below.

          if @user.stripe_errors.blank?
            $analytics.added_credit_card(@user)
            notice = "Thanks for subscribing! You are awesome."

            SystemMailer.new_subscription_email(@user.id).deliver_later!
          end
        end

      else
        notice = "Sorry, something seems to have gone wrong. Please try again, or contact support@appcanary.com"
      end
    else
      notice = "Were you trying to change a setting? You may have missed a field."
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to dashboard_path, notice: notice }
      else
        @billing_presenter = BillingManager.new(@user).to_presenter
        @servers_count = @user.servers_count
        @active_servers_count = @user.active_servers_count
        @monitors_count = @user.monitors_count

        format.html { render :show }
      end
    end
  end


  def stripe_params
    params.require(:user).permit(:stripe_token, :subscription_plan)
  end

  def set_vars
    @show_stripe = true
    @user = current_user
    @agent_token = @user.agent_token
    @billing_manager = BillingManager.new(@user)
    @billing_presenter = @billing_manager.to_presenter
    @active_servers_count = @user.active_servers_count
    @servers_count = @user.servers_count
    @monitors_count = @user.monitors_count
  end
end

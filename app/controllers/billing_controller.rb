class BillingController < ApplicationController
  before_action :set_vars
  def show
  end

  def update
    if params[:user].nil?
      notice = "Were you trying to change a setting? You may have missed a field."
    else
      sub_id = stripe_params[:subscription_plan]
      stripe_token = stripe_params[:stripe_token]

      notice = ""
      if sub_id.present?
        @user, action = @billing_manager.change_subscription!(sub_id)
        case action
        when :canceled
          notice = "You've successfully canceled your subscription. Sorry to see you go!"
          SystemMailer.canceled_subscription_email(@user.id).deliver_later!
          $analytics.canceled_subscription(@user)
        when :changed
          notice = "You've changed your plan!"
          SystemMailer.subscription_plan_changed(@user.id, sub_id).deliver_later!
        when :invalid
          notice = "Sorry, you can't select that plan. Please try again or contact us at support@appcanary.com"
        when :none
          #nop
        else
          @user.errors.add(:base, "Sorry, something seems to have gone wrong with changing your subscription. Please try again, or contact support@appcanary.com")
        end
      end

      if stripe_token.present?
        @user, action = @billing_manager.change_token!(stripe_token)
        case action
        when :added
          notice += "Thanks for subscribing! You are awesome."
          SystemMailer.new_subscription_email(@user.id).deliver_later!
          $analytics.added_credit_card(@user)
        when :changed
          notice += "You've successfully changed your credit card!"
          SystemMailer.credit_card_changed(@user.id).deliver_later!
        else
          @user.errors.add(:base, "Sorry, something seems to have gone wrong with changing your card. Please try again, or contact support@appcanary.com")
        end
      end
    end
    # clear notice if it's empty
    if notice.blank?
      notice = nil
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

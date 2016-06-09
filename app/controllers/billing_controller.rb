class BillingController < ApplicationController
  def show
    @show_stripe = true
    @user = current_user
    @billing_presenter = BillingManager.new(@user).to_presenter
  end

  def update
    @show_stripe = true
    @user = current_user
    @billing_manager = BillingManager.new(@user)
    notice = "You've successfully changed your billing settings. Thanks!" 

    if params[:user]
      sub_plan = params[:user][:subscription_plan]

      if @billing_manager.cancel_subscription?(sub_plan)
        @user = @billing_manager.cancel_subscription!
        notice = "You've successfully canceled your subscription. Sorry to see you go!" 

        track_event @user, "Canceled subscription"
        Raven.capture_message("Subscription canceled by: #{@user.email}")

      elsif (sub = @billing_manager.valid_subscription?(sub_plan))
        if stripe_params[:stripe_token].blank?
          @user = @billing_manager.change_subscription!(sub)
        else
          @user = @billing_manager.add_customer(params[:stripe_token], sub)

          # if these are stripe errors, the validation
          # on user.save below will trigger them to
          # show up below.

          if @user.stripe_errors.blank?
            track_event @user, "Added credit card"
            notice = "Thanks for subscribing! You are awesome."

            Raven.capture_message("Subscription added by: #{@user.email}")
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

end

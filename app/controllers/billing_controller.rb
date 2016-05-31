class BillingController < ApplicationController
  def show
    @show_stripe = true
    @user = current_user
    @billing_view = BillingManager.new(@user).to_view
  end

  def update
    @show_stripe = true
    @user = current_user
    @billing_manager = BillingManager.new(@user)
    notice = "You've successfully changed your billing settings. Thanks!" 

    if params[:user]
      # @user.subscription_plan = params[:user][:subscription_plan]


      sub_plan = params[:user][:subscription_plan]
      case sub = @billing_manager.validate_subscription(sub_plan)
      when BillingPlan::Subscription
        if stripe_params[:stripe_token]
          if customer = @billing_manager.add_customer(params[:stripe_token])
            @user = @billing_manager.set_subscription(customer.id, sub)

            track_event @user, "Added credit card"
            notice = "Thanks for subscribing! You are awesome."

            Raven.capture_message("Subscription added by: #{@user.email}")
          end
        else
          @user = @billing_manager.change_subscription!(sub)
          notice = "You've successfully changed your billing settings. Thanks!" 
        end

      when :cancel
        @user = @billing_manager.cancel_subscription!
        notice = "You've successfully canceled your subscription. Sorry to see you go!" 

        track_event @user, "Canceled subscription"
        Raven.capture_message("Subscription canceled by: #{@user.email}")

      else
        notice = "Sorry, something seems to have gone wrong. Please try again, or contact support@appcanary.com"
      end

# TO BE DELETED 
#       if @user.valid? && @user.subscription_plan.present?
#         # was a cc also submitted?
#         if stripe_token = stripe_params[:stripe_token]
#           customer = BillingManager.add_customer(stripe_token, @user)
#           if customer
#             # hack to get strong params to shut up
#             # about empty params
#             @user.stripe_customer_id = customer.id
#             track_event @user, "Added credit card"
#             notice = "Thanks for subscribing! You are awesome."
# 
#             Raven.capture_message("Subscription added by: #{@user.email}")
#           end
#         end
# 
#         if @user.subscription_plan == DeprecatedSubscriptionPlan::CANCEL
#           track_event @user, "Canceled subscription"
#           Raven.capture_message("Subscription canceled by: #{@user.email}")
# 
#           @user.stripe_customer_id = nil
#           @user.subscription_plan = nil
#         end
#       end

    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to dashboard_path, notice: notice }
      else
        format.html { render :show }
      end
    end
  end


  def stripe_params
    params.require(:user).permit(:stripe_token, :subscription_plan)
  end

end

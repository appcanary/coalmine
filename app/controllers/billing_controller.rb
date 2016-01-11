class BillingController < ApplicationController
  def show
    @show_stripe = true
    @user = current_user
  end

  def update
    @show_stripe = true
    @user = current_user
    notice = "You've successfully changed your billing settings. Thanks!" 

    @user.subscription_plan = params[:user][:subscription_plan]
    if @user.valid? && @user.subscription_plan.present?
      # was a cc also submitted?
      if stripe_token = stripe_params[:stripe_token]
        customer = Billing.add_customer(stripe_token, @user)
        if customer
          # hack to get strong params to shut up
          # about empty params
          @user.stripe_customer_id = customer.id
          track_event @user, "Added credit card"
          notice = "Thanks for subscribing! You are awesome."
          
          Raven.capture_message("Subscription added by: #{@user.email}")
        end
      end

      if @user.subscription_plan == SubscriptionPlan::CANCEL
        track_event @user, "Canceled subscription"
        Raven.capture_message("Subscription canceled by: #{@user.email}")
        
        @user.stripe_customer_id = nil
        @user.subscription_plan = nil
      end
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

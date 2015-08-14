class BillingController < ApplicationController
  def show
    @show_stripe = true
    @user = current_user
  end

  def update
    @user = current_user

    @user.subscription_plan = params[:user][:subscription_plan]
    if @user.valid? && @user.subscription_plan.present?
      # was a cc also submitted?
      if stripe_token = stripe_params[:stripe_token]
        customer = Billing.add_customer(stripe_token, @user)
        if customer
          # hack to get strong params to shut up
          # about empty params
          @user.stripe_customer_id = customer.id
        end
      end

      if @user.subscription_plan == SubscriptionPlan::CANCEL
        @user.stripe_customer_id = nil
        @user.subscription_plan = nil
      end
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to dashboard_path, notice: "You've successfully changed your billing settings. Thanks!" }
      else
        format.html { render :show }
      end
    end
  end


  def stripe_params
    params.require(:user).permit(:stripe_token, :subscription_plan)
  end

end

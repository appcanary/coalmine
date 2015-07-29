class BillingController < ApplicationController
  def show
    @show_stripe = true
  end

  def update
    @user = current_user

    if stripe_token = stripe_params[:stripe_token]
      customer = Billing.add_customer(stripe_token, @user)
      if customer
        # hack to get strong params to shut up
        # about empty params
        @user.stripe_customer_id = customer.id
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
    params.require(:user).permit(:stripe_token)
  end

end

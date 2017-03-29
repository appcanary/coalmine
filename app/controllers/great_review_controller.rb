class GreatReviewController < ApplicationController
  skip_before_filter :require_login
  # before_filter :require_great_review_login, :except => [:hello, :sign_up]

  layout 'great_review'
  def index
  end

  def show
    @show_stripe = true
    @user = current_user
  end

  def hello
    @user = User.new
  end

  def sign_up

    if @user = login(user_params[:email], user_params[:password])
      redirect_to great_review_path
    else
      @user = User.new(user_params)

      respond_to do |format|
        if UserManager.sign_up(@user)
          auto_login(@user)
          format.html { redirect_to great_review_path }
        else
          format.html { render :hello }
        end
      end
    end
  end

  def payment
    @user = current_user

    if stripe_token = stripe_params[:stripe_token]
      # this method was deprecated and would have thrown an exception
      # We're not doing this / not showing a payment page anymore anyways
      # TODO: delete this controlelr/routes
      customer = BillingManager.add_customer(stripe_token, @user)
      if customer
        # hack to get strong params to shut up
        # about empty params
        @user.stripe_customer_id = customer.id
      end
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to great_review_path, notice: "Great to have you. We'll be in touch soon." }
      else
        format.html { render :show }
      end
    end
  end


  def stripe_params
    params.require(:user).permit(:stripe_token)
  end

  def require_great_review_login
    unless current_user
      redirect_to great_review_login_path
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :onboarded, :beta_signup_source)
  end

end

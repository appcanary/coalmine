class BillingManager
  attr_accessor :user, :billing_plan
  def self.find_customer(user)
    self.new(user).find_customer()
  end

  def initialize(user)
    self.user = user
    self.billing_plan = user.billing_plan || user.build_billing_plan
  end

  def find_customer
    Stripe::Customer.retrieve(@user.stripe_customer_id)
  end

  def add_customer(stripe_token)
    stripe_wrapper do
      customer = Stripe::Customer.create(
        :source => stripe_token,
        :email => @user.email
      )
      @user.stripe_customer_id = customer.id
    end
  end

  def update_customer(stripe_token)
    stripe_wrapper do
      customer = find_customer
      customer.source = stripe_token
      customer.save
    end
  end

  def stripe_wrapper(&block)
    begin
      block.call()
    rescue Stripe::CardError => e
      Raven.capture_exception(e)
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]

      puts "Status is: #{e.http_status}"
      puts "Type is: #{err[:type]}"
      puts "Code is: #{err[:code]}"
      # param is '' in this case
      puts "Param is: #{err[:param]}"
      puts "Message is: #{err[:message]}"
      @user.stripe_errors << err[:message]
    rescue Stripe::InvalidRequestError => e
      Raven.capture_exception(e)
      # Invalid parameters were supplied to Stripe's API
      @user.stripe_errors << "Invalid paramemters supplied to Stripe. Sorry, probably our fault."
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
      Raven.capture_exception(e)
      @user.stripe_errors << "Stripe authentication failure. Sorry, probably our fault."
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
      Raven.capture_exception(e)
      @user.stripe_errors << "Stripe seems to be down. Please try again in a bit."
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
      Raven.capture_exception(e)
      @user.stripe_errors << "Something went wrong with Stripe. We're looking into it."
    rescue => e
      Raven.capture_exception(e)
      @user.stripe_errors << "Something went wrong with this transaction. We're looking into it."
    end
  end

  def valid_subscription?(sub_id)
    self.billing_plan.subscription_plans.find_by_id(sub_id)
  end

  def change_subscription!(sub_id)
    if sub_id == BillingPresenter::CANCEL
      @user.billing_plan.reset_subscription
      return @user, :canceled
    elsif sub_id.to_i == self.billing_plan.subscription_plan_id
      return @user, :none
    elsif valid_subscription?(sub_id)
      # did we add or change?
      old_sub = self.billing_plan.subscription_plan_id
      self.billing_plan.subscription_plan_id = sub_id
      if old_sub.present?
        return @user, :changed
      else
        return @user, :added
      end
    else
      return @user, :invalid
    end
  end

  def change_token!(token)
    if @user.stripe_customer_id.nil?
      add_customer(token)
      return @user, :added
    else
      update_customer(token)
      return @user, :changed
    end
  end

  def set_available_subscriptions!(ids)
    @user.billing_plan.available_subscription_plans = ids
    @user
  end

  def to_presenter
    BillingPresenter.new(self.billing_plan)
  end
end

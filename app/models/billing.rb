class Billing
  def initialize(user)
    @user = user
  end

  def self.add_customer(stripe_token, user)
    self.new(user).add_customer(stripe_token)
  end

  def self.find_customer(user)
    self.new(user).find_customer()
  end

  def find_customer
    customer = Stripe::Customer.retrieve(@user.stripe_customer_id)
  end

  def add_customer(stripe_token)
    customer = nil
    stripe_wrapper do 
      customer = Stripe::Customer.create(
        :source => stripe_token,
        :email => @user.email
      )
    end
    return customer
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
end

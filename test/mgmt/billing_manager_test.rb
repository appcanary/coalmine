require 'test_helper'

class BillingManagerTest <ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @sub1 = FactoryGirl.create(:subscription_plan)
    @sub2 = FactoryGirl.create(:subscription_plan)
    @unavailable_sub = FactoryGirl.create(:subscription_plan)
    # User only had available subscription
    @user.create_billing_plan
    @user.billing_plan.available_subscription_plans = [@sub1.id, @sub2.id]
    @user.save
    @bm = BillingManager.new(@user.reload)

  end

  describe "change_subscription!" do
    it "should return add a subscription if none exists" do
      assert_nil @user.billing_plan.subscription_plan_id

      @user, action = @bm.change_subscription!(@sub1.id)
      assert_equal :added, action

      @user.save
      assert_equal @sub1.id, @user.billing_plan.subscription_plan_id
    end

    it "should do nothing if subscription is unchanged" do
      @bm.billing_plan.subscription_plan_id = @sub1.id
      @bm.billing_plan.save
      assert_equal @sub1.id, @user.billing_plan.subscription_plan_id

      @user, action = @bm.change_subscription!(@sub1.id)
      assert_equal :none, action

      @user.save
      assert_equal @sub1.id, @user.billing_plan.subscription_plan_id
    end

    it "should change the subscription if one exists already" do
      @user.billing_plan.subscription_plan_id = @sub1.id
      @user.billing_plan.save
      assert_equal @sub1.id, @user.billing_plan.subscription_plan_id

      @user, action = @bm.change_subscription!(@sub2.id)
      assert_equal :changed, action

      @user.save
      assert_equal @sub2.id, @user.billing_plan.subscription_plan_id
    end

    it "should return invalid when it's not a valid subscription" do
      assert_nil @user.billing_plan.subscription_plan_id

      @user, action = @bm.change_subscription!(@unavailable_sub.id)
      assert_equal :invalid, action

      @user.save
      assert_nil @user.billing_plan.subscription_plan_id
    end

    it "should cancel a subscription if cancel is selected" do
      @user.billing_plan.subscription_plan_id = @sub1.id
      @user.billing_plan.save
      assert_equal @sub1.id, @user.billing_plan.subscription_plan_id

      @user, action = @bm.change_subscription!(BillingPresenter::CANCEL)
      assert_equal :canceled, action

      @user.save
      assert_nil @user.billing_plan.subscription_plan_id
    end
  end

  describe "change_token!!" do
    it "should create a stripe customer when adding a credit card" do
      token = "TOKEN"
      stripe_id = "STRIPEID"
      customer = mock()
      customer.expects(:id).returns(stripe_id).at_least_once
      Stripe::Customer.expects(:create).with({:source => token, :email => @user.email}).returns(customer).at_least_once

      assert_nil @user.stripe_customer_id

      # Add the card
      @user, action = @bm.change_token!(token)
      assert_equal :added, action

      @user.save
      assert_equal stripe_id, @user.stripe_customer_id
    end

    it "should change the credit card when changing the user" do
      token = "TOKEN"
      stripe_id = "STRIPEID"
      @user.stripe_customer_id = stripe_id
      @user.save

      customer = mock()
      Stripe::Customer.expects(:retrieve).with(stripe_id).returns(customer).at_least_once
      customer.expects(:source=).with(token).at_least_once
      customer.expects(:save).at_least_once

      #Change the card
      @user, action = @bm.change_token!(token)
      assert_equal :changed, action

      @user.save
      # customer id stayed the same
      assert_equal stripe_id, @user.stripe_customer_id
    end
  end
end

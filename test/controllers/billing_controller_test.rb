require 'test_helper'

class BillingControllerTest < ActionController::TestCase

  let(:user) { FactoryGirl.create(:user) }
  describe "Logged in" do
    before do
      login_user(user)
    end

    test "should not perform stripe song and dance absent subscription plan" do

      token = nil
      VCR.use_cassette("new_stripe_customer") do
        token = create_token
      end
      # no vcr cos talking to stripe at all is an error here
      put :update, user: { stripe_token: token.id }
      assert_equal false, user.stripe_customer_id.present?
      assert_redirected_to dashboard_path
    end

    test "should perform the stripe song and dance" do
      VCR.use_cassette("new_stripe_customer") do
        token = create_token
        put :update, user: { stripe_token: token.id, subscription_plan: SubscriptionPlan::AC_STARTER }
        assert_equal true, user.stripe_customer_id.present?
        assert_redirected_to dashboard_path
      end
    end

    test "should delete customer id if sub is cancelled" do
      user.subscription_plan = SubscriptionPlan::AC_STARTER
      user.stripe_customer_id = "test"
      user.save!

      put :update, user: { subscription_plan: SubscriptionPlan::CANCEL }

      assert user.stripe_customer_id.blank?
      assert user.subscription_plan.blank?
      assert_redirected_to dashboard_path
    end

    test "should not allow discount plans if user is not from beta" do

      # prevent caring about servers_count api call
      user.stubs(:servers_count).with(anything).returns(3)

      put :update, user: { subscription_plan: SubscriptionPlan::AC_DISCOUNT_STARTER }

      user.reload
      assert user.stripe_customer_id.blank?
      assert user.subscription_plan.blank?
      assert_response :success
      assert_template :show
    end

    test "should allow discount plans if user is from beta" do
      user.beta_signup_source = "test"

      VCR.use_cassette("new_stripe_customer") do
        token = create_token
        put :update, user: { stripe_token: token.id, subscription_plan: SubscriptionPlan::AC_DISCOUNT_STARTER }
      end

      user.reload
      assert user.stripe_customer_id.present?
      assert_equal SubscriptionPlan::AC_DISCOUNT_STARTER, user.subscription_plan
      assert_redirected_to dashboard_path
    end

    test "should pop out an error when given a bad card" do
      user.stubs(:servers_count).with(anything).returns(3)
      
      VCR.use_cassette("bad_stripe_card") do
        token = create_declined_token
        put :update, user: { stripe_token: token.id, subscription_plan: SubscriptionPlan::AC_STARTER }

        assert_equal false, user.stripe_customer_id.present?
        assert_equal true, user.errors.present?
        assert_response :success
        assert_template :show

      end
    end

    it "should not fail when given no params" do
      begin
        put :update
      rescue NoMethodError
        assert false
      end
    end


  end


  # we won't be getting any bad tokens since 
  # it's all handled js side. When the time 
  # comes to support changing credit cards,
  # add that test.

  def create_token(year = nil)
    Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 7,
        :exp_year => 2019,
        :cvc => "314"
      }
    )
  end

  def create_declined_token(year = nil)
    Stripe::Token.create(
      :card => {
        :number => "4000000000000002",
        :exp_month => 7,
        :exp_year => 2019,
        :cvc => "314"
      }
    )
  end

end

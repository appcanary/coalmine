require 'test_helper'

class BillingControllerTest < ActionController::TestCase

  let(:user) { FactoryGirl.create(:user) }

  test "should perform the stripe song and dance" do
    login_user(user)
    VCR.use_cassette("new_stripe_customer") do
      token = create_token
      put :update, user: { stripe_token: token.id }
      assert_equal true, user.stripe_customer_id.present?
      assert_redirected_to dashboard_path
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
        :exp_year => 2.years.from_now.year,
        :cvc => "314"
      }
    )
  end
end

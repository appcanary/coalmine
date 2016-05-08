require 'test_helper'

class OnboardingControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }

  describe "while authenticated" do
    setup do 
      login_user(user)
    end

    test "should get welcome" do
      get :welcome
      assert_response :success
    end
  end

  describe "while unauthenticated" do
    it "should get redirected" do
      get :welcome
      assert_response :redirect
    end
  end
end

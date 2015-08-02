require 'test_helper'

# No need for this test in yc demo
class WelcomeControllerTest < ActionController::TestCase
  describe "while authenticated" do
    let(:user) { FactoryGirl.create(:user) }

    it "should redirect to dashboard" do
      login_user(user)
      get :index
      assert_redirected_to dashboard_path 
    end
  end

  describe "while unauthenticated" do
    it "should get the front page" do
      get :index
      assert_response :success

      assert_select("#new_pre_user")
    end 
  end
end

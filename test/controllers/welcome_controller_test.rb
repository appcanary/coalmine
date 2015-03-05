require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  describe "while authenticated" do
    let(:user) { FactoryGirl.create(:user) }

    it "should redirect to dashboard" do
      login_user(user)
      get :index
      assert_redirected_to dashboard_path
    end
  end
end

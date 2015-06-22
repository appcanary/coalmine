require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  setup do
    Canary.any_instance.stubs(:servers).with(anything).returns([])
  end
  describe "while authenticated" do
    # TODO: missing VCR
    let(:user) { FactoryGirl.create(:user) }
    it "should get index" do
      login_user(user)
      get :index
      assert_response :success
    end
  end

  describe "while unauthenticated" do
    it "should not get index" do
      get :index
      assert_response :redirect
    end
  end
end

require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  describe "while authenticated" do
    let(:user) { FactoryGirl.create(:user) }
    describe "while onboarded" do
      it "should get index" do
        Canary.any_instance.stubs(:servers).with(anything).returns([FactoryGirl.build(:server)])
        login_user(user)
        get :index
        assert_response :success
      end
    end

    describe "while not onboarded" do
      it "should be redirected to servers/new" do
        Canary.any_instance.stubs(:servers).with(anything).returns([])
        login_user(user)

        get :index
        assert_redirected_to onboarding_path
      end
    end
  end

  describe "while unauthenticated" do
    it "should not get index" do
      get :index
      assert_response :redirect
    end
  end
end

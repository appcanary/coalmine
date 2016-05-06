require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  describe "while authenticated" do
    let(:user) { FactoryGirl.create(:user) }
    describe "while onboarded" do
      it "should get index" do
        Server.stubs(:find_all).with(anything).returns([FactoryGirl.build(:server)])
        Moniter.stubs(:find_all).with(anything).returns([FactoryGirl.build(:moniter)])
        login_user(user)
        get :index
        assert_response :success
      end
    end

    describe "while not onboarded" do
      it "should be redirected to servers/new" do
        Server.stubs(:find_all).with(anything).returns([])
        Moniter.stubs(:find_all).with(anything).returns([FactoryGirl.build(:moniter)])
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

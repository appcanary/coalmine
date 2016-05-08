require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  describe "while authenticated" do
    setup do 
      login_user(user)
    end

    let(:user) { FactoryGirl.create(:user) }
    describe "while onboarded" do

      it "should get index with a new server" do
        Server.stubs(:find_all).with(anything).returns([FactoryGirl.build(:server)])
        Moniter.stubs(:find_all).with(anything).returns([])
        get :index
        assert_response :success
      end

      it "should get index with a new monitor" do
        Server.stubs(:find_all).with(anything).returns([])
        Moniter.stubs(:find_all).with(anything).returns([FactoryGirl.build(:moniter)])
        get :index
        assert_response :success
      end

    end

    describe "while not onboarded" do
      it "should be redirected to onboarding path" do
        Server.stubs(:find_all).with(anything).returns([])
        Moniter.stubs(:find_all).with(anything).returns([])

        get :index
        assert_redirected_to onboarding_path
      end

      it "but tried to add a server, should display flash" do
        Server.stubs(:find_all).with(anything).returns([])
        Moniter.stubs(:find_all).with(anything).returns([])

        get :index, :done => true
        assert(flash[:notice] =~ /hello@appcanary/)
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

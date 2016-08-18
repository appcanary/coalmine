require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  describe "while authenticated" do
    setup do 
      login_user(user)
    end

    let(:user) { FactoryGirl.create(:user) }
    describe "while onboarded" do

      it "should get index with a new server" do
        FactoryGirl.create(:agent_server, :account => user.account)
        get :index
        assert_response :success
      end

      it "should get index with a new monitor" do
        FactoryGirl.create(:bundle, :account => user.account)
        
        get :index
        assert_response :success
      end

    end

    describe "while not onboarded" do
      it "should be redirected to onboarding path" do
        get :index
        assert_redirected_to onboarding_path
      end

      it "but tried to add a server, should display flash" do
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

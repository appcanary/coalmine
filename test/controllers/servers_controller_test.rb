require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:server) { FactoryGirl.build(:server) }

  before(:suite) do
    Canary.any_instance.stubs(:server).with(anything).returns(server)
  end

  describe "while authenticated" do

    setup do
      login_user(user)
    end

    it "should show the show page" do
      get :show, :id => "1234"
      assert_response :success
    end

    it "should show the new page" do
      User.any_instance.stubs(:agent_token).returns("1234")
      get :new
      assert_response :success
      assert assigns(:agent_token)
    end
  end

  describe "while unauthenticated" do
    it "show should be redirected" do
      get :show, :id => "1234"
      assert_response :redirect
    end

    it "new should be redirected" do
      get :new
      assert_response :redirect
    end

  end
end

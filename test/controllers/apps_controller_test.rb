require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:server) { FactoryGirl.build(:server) }
  let(:app) { FactoryGirl.build(:app) }

  before(:suite) do
    App.stubs(:find).returns(app)
    Server.stubs(:find).returns(server)
  end

  describe "while authenticated" do

    setup do
      login_user(user)
    end

    it "should show the show page" do
      get :show, :server_id => 1234, :id => 1234
      assert_response :success
    end
  end

  describe "while unauthenticated" do
    it "show should be redirected" do
      get :show, :server_id => 1234, :id => "1234"
      assert_response :redirect
    end

    it "new should be redirected" do
      get :new, :server_id => 1234
      assert_response :redirect
    end

  end

end

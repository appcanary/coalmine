require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }

  setup do
    bundle = FactoryGirl.create(:bundle_with_packages, :account => user.account, :id => 1235)
    server = FactoryGirl.create(:agent_server, :account => user.account, :id => 1234, :bundles => [bundle])
  end

  describe "while authenticated" do

    setup do
      login_user(user)
    end

    it "should show the show page" do
      get :show, :server_id => 1234, :id => 1235
      assert_response :success
    end

    it "should delete the bundle" do
      bundle = FactoryGirl.create(:bundle, :account_id => user.account_id)
      assert_equal 2, Bundle.count

      delete :destroy, :server_id => 1234, :id => bundle.id
      assert_response :redirect

      assert_equal 1, Bundle.count
    end

  end

  describe "while unauthenticated" do
    it "show should be redirected" do
      get :show, :server_id => 1234, :id => "1235"
      assert_response :redirect
    end

    it "new should be redirected" do
      get :new, :server_id => 1234
      assert_response :redirect
    end

  end

end

require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin_user) }

  setup do
    bundle = FactoryGirl.create(:bundle_with_packages, :account => user.account, :id => 1235)
    vuln = FactoryGirl.create(:vulnerability, :pkgs => bundle.packages[0..1])
    LogResolution.resolve_package(user, bundle.packages[0])
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

    it "shouldn't show another user's bundle" do
      bundle2 = FactoryGirl.create(:bundle_with_packages, :account => user2.account)
      server2 = FactoryGirl.create(:agent_server, :account => user2.account, :bundles => [bundle2])
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, :server_id => server2.id, :id => bundle2.id
      end
    end

  end

  describe "while admin" do
    setup do
      login_user(admin)
    end

    it "should show another user's app" do
      bundle2 = FactoryGirl.create(:bundle_with_packages, :account => user2.account)
      server2 = FactoryGirl.create(:agent_server, :account => user2.account, :bundles => [bundle2])
      get :show, :id => bundle2.id, :server_id => server2.id
      assert_response :success
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

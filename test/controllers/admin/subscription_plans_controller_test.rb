require 'test_helper'

class Admin::SubscriptionPlansControllerTest < ActionController::TestCase
  setup do
    @admin_subscription_plan = FactoryGirl.create(:subscription_plan)
  end

  let(:normal_user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }

  describe 'while logged in as a normal user' do
    setup do
      login_user(normal_user)
    end

    it "should not get index" do
      get :index
      assert_redirected_to login_path
    end

    it "should not allow posting stuff" do
      post :create, :id => 1234, :user => { :anything => :really }
      assert_redirected_to login_path
    end

    it "should also not allow putting stuff" do
      put :update, :id => 1234, :user => { :anything => :really }
      assert_redirected_to login_path
    end

  end

  describe "while unauthenticated" do
    it "should not get index" do
      get :index
      assert_redirected_to login_path
    end

    it "should not allow posting stuff" do
      post :create, :id => 1234, :user => { :anything => :really }
      assert_redirected_to login_path
    end

    it "should also not allow putting stuff" do
      put :update, :id => 1234, :user => { :anything => :really }
      assert_redirected_to login_path
    end
  end

  describe "while logged in as admin" do
    setup do 
      login_user(admin_user)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:admin_subscription_plans)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create admin_subscription_plan" do
      assert_difference('SubscriptionPlan.count') do
        post :create, subscription_plan: { :value => 100 }
      end

      assert_redirected_to admin_subscription_plan_path(assigns(:admin_subscription_plan))
    end

    test "should show admin_subscription_plan" do
      get :show, id: @admin_subscription_plan
      assert_response :success
    end

    test "should update admin_subscription_plan" do
      patch :update, id: @admin_subscription_plan, subscription_plan: { :value => 200  }
      assert_redirected_to admin_subscription_plan_path(assigns(:admin_subscription_plan))
    end

    test "should destroy admin_subscription_plan" do
      assert_difference('SubscriptionPlan.count', -1) do
        delete :destroy, id: @admin_subscription_plan
      end

      assert_redirected_to admin_subscription_plans_path
    end
  end
end

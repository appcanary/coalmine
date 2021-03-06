require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let(:normal_user) { FactoryGirl.create(:user) }

  describe "not admins" do
    setup do
      login_user(normal_user)
    end
    it "should not like not admins" do
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

  describe "not authenticated" do
     it "should not like non users" do
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


  describe "yay admins" do
    setup do 
      login_user(admin_user)
    end

    it "should let them see stuff" do
      User.any_instance.stubs(:datomic_id).returns(12345)
      
      get :index
      assert_response :success
    end

    it "should let them create users" do
      # TODO: find a way to share this with other users test
      
      assert_difference('User.count') do
        post :create, :user => { 
          :email => Faker::Internet.email,
          :password => TestValues::PASSWORD,
          :password_confirmation => TestValues::PASSWORD }
      end
    end

    it "should let them edit users" do
      put :update, :id => normal_user.id, :user => { 
        :password => TestValues::PASSWORD,
        :password_confirmation => TestValues::PASSWORD }


      assert_equal "User was successfully updated.",  flash["notice"]

      assert_response :redirect
    end

    it "should allow us to wear the flesh of others" do
      assert_equal admin_user, current_user
      
      post :impersonate, :id => normal_user.id

      assert_equal normal_user, current_user
      assert_equal admin_user, true_user
    end

    def current_user
      @controller.send(:current_user)
    end

    def true_user
      @controller.send(:true_user)
    end
  end
end 

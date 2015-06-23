require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let(:non_admin_user) { FactoryGirl.create(:user) }

  describe "not admins" do
    setup do
      login_user(non_admin_user)
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
      get :index
      assert_response :success
    end

    it "should let them create users" do
      client = mock
      client.expects(:add_user).with(anything).returns({'web-token' => 'a token'})
      Canary.stubs(:new).with(anything).returns(client)

      assert_difference('User.count') do
        post :create, :user => { :email => Faker::Internet.email,
                                 :password => TestValues::PASSWORD,
                                 :password_confirmation => TestValues::PASSWORD }
      end
    end

    it "should let them edit users" do
      put :update, :id => non_admin_user.id, :user => { 
                              :password => TestValues::PASSWORD,
                              :password_confirmation => TestValues::PASSWORD }


      assert_equal "User was successfully updated.",  flash["notice"]

      assert_response :redirect
    end
  end

  # TODO: test impersonation


  # setup do
  #   @admin_user = admin_users(:one)
  # end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:admin_users)
  # end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create admin_user" do
  #   assert_difference('Admin::User.count') do
  #     post :create, admin_user: { email: @admin_user.email, onboarded: @admin_user.onboarded }
  #   end

  #   assert_redirected_to admin_user_path(assigns(:admin_user))
  # end

  # test "should show admin_user" do
  #   get :show, id: @admin_user
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get :edit, id: @admin_user
  #   assert_response :success
  # end

  # test "should update admin_user" do
  #   patch :update, id: @admin_user, admin_user: { email: @admin_user.email, onboarded: @admin_user.onboarded }
  #   assert_redirected_to admin_user_path(assigns(:admin_user))
  # end

  # test "should destroy admin_user" do
  #   assert_difference('Admin::User.count', -1) do
  #     delete :destroy, id: @admin_user
  #   end

  #   assert_redirected_to admin_users_path
  # end
end 

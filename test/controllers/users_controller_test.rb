require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  describe "new user" do
    it "should display signup page" do
      get :new
      assert_response :success
      assert_not_nil assigns(:user)
    end

    it "should register new users" do
      # surely there exists a better way to do this?
      Canary.stub :create_user, "a token" do

        assert_difference('User.count') do
          post :create, :user => { :email => Faker::Internet.email, 
                                   :password => TestValues::PASSWORD,
                                   :password_confirmation => TestValues::PASSWORD }
        end
      end

      assert assigns(:current_user)
      assert_redirected_to user_path(assigns(:user))
    end
  end
  # 
  #   test "should get index" do
  #     get :index
  #     assert_response :success
  #     assert_not_nil assigns(:users)
  #   end
  # 
  #   test "should get new" do
  #     get :new
  #     assert_response :success
  #   end
  # 
  #   test "should create user" do
  #     assert_difference('User.count') do
  #       post :create, user: { crypted_password: @user.crypted_password, email: @user.email, salt: @user.salt }
  #     end
  # 
  #     assert_redirected_to user_path(assigns(:user))
  #   end
  # 
  #   test "should show user" do
  #     get :show, id: @user
  #     assert_response :success
  #   end
  # 
  #   test "should get edit" do
  #     get :edit, id: @user
  #     assert_response :success
  #   end
  # 
  #   test "should update user" do
  #     patch :update, id: @user, user: { crypted_password: @user.crypted_password, email: @user.email, salt: @user.salt }
  #     assert_redirected_to user_path(assigns(:user))
  #   end
  # 
  #   test "should destroy user" do
  #     assert_difference('User.count', -1) do
  #       delete :destroy, id: @user
  #     end
  # 
  #     assert_redirected_to users_path
  #   end
end

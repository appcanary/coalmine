require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  describe "new user" do
    it "should display signup page" do
      get :new
      assert_response :success
      assert_not_nil assigns(:user)
    end

    it "should register new users and log them in" do
      client = mock
      client.expects(:add_user).with(anything).returns({'web-token' => 'a token'})
      Canary.stubs(:new).with(anything).returns(client)

      assert_difference('User.count') do
        post :create, :user => { :email => Faker::Internet.email,
          :password => TestValues::PASSWORD,
          :password_confirmation => TestValues::PASSWORD }
      end
      assert assigns(:current_user)
      assert_redirected_to dashboard_path
    end
  end

  describe "existing user" do
    let(:user) { FactoryGirl.create(:user) }
    it "should redirect if logged in" do
      login_user(user)
      get :new
      assert_redirected_to dashboard_path
    end

    it "should fail if email is taken" do

      post :create, :user => { :email => user.email,
                               :password => TestValues::PASSWORD,
                               :password_confirmation => TestValues::PASSWORD }

      assert_template :new
      assert_nil assigns(:current_user)
      assert assigns(:user).errors.present?
    end

    it "should not have any user deletion implemented atm" do
      login_user(user)
      assert_no_difference 'User.count' do
        post :destroy, :id => user.id
        assert_redirected_to dashboard_path
      end

      # TODO: test who can update what,
      # test not being able to see stuff while logged out.
    end

  end

  describe "admin users" do
    let(:normal_user) { FactoryGirl.create(:user) }
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    it "should shed our mortail coil" do
      login_user(admin_user)
      @controller.impersonate_user(normal_user)

      assert_equal normal_user, current_user
      post :stop_impersonating

      assert_equal admin_user, current_user
    end

     def current_user
      @controller.send(:current_user)
    end

  end
 end

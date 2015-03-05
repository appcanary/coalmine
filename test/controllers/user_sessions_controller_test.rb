require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  describe "login page" do
    let(:user) { FactoryGirl.create(:user) }
    it "should display the login page" do
      get :new
      assert_template("new")
      assert_response :success
    end

    it "should login users" do
      post :create, :user => {:email => user.email, :password => TestValues::PASSWORD}
      assert assigns(:current_user)
      assert_redirected_to dashboard_path
    end

    it "should fail bad logins" do
      post :create, user => {:email => user.email, :password => "gibberish"}
      assert_template :new
    end

    it "should redirect if logged in" do
      login_user(user)
      get :new
      assert_redirected_to dashboard_path
    end

    it "should log out" do
      login_user(user)
      post :destroy
      assert_redirected_to root_path
      assert_nil assigns(:current_user)
    end
  end

end

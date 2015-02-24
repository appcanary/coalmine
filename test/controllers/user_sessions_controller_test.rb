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
      assert_redirected_to users_path
    end

    it "should fail bad logins" do
      post :create, user => {:email => user.email, :password => "gibberish"}
      assert_template :new
    end
  end

  # test logout?
end

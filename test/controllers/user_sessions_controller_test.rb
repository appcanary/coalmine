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

    it "should login via json" do
      assert_nil assigns(:current_user)
      @request.headers["Accept"] = "application/json" 
      post :create, {:user => {:email => user.email, :password => TestValues::PASSWORD}}, :type => :json
      assert assigns(:current_user)
      json_hsh = JSON.parse(response.body)
      assert json_hsh["user"]
      assert json_hsh["user"]["email"]
      assert_nil json_hsh["crypted_password"]
      assert_nil json_hsh["user"]["crypted_password"]
    end

    it "should fail bad login via json" do
      assert_nil assigns(:current_user)
      @request.headers["Accept"] = "application/json" 
      post :create, {:user => {:email => user.email, :password => "gibberish"}}.to_json
      hsh = JSON.parse(response.body)
      assert_equal hsh["full_messages"], ["Invalid email or password."]
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

  describe "pwd resets" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      # silence mailer issues
      @mock_mailer = mock("mailer")
      @mock_mailer.stubs(:deliver).returns(true)
      @mock_mailer 
    end

    it "should send pw resets" do
      # check that emails get called
      UserMailer.stubs(:reset_password_email).with(anything).returns(@mock_mailer).once

      assert_nil user.reset_password_token
      post :create, {:user => {:email => user.email }, :password_reset => "true"}
      assert_redirected_to login_path

      assert_nil user.reset_password_token
      # refetch obj
      user.reload
      assert_not_nil user.reset_password_token

      assert_equal flash[:notice], "We've sent a reset to your email!"

      # OK. Let's whether we can trigger multiple emails
      post :create, {:user => {:email => user.email }, :password_reset => "true"}
      assert_equal flash[:notice], "Seems like we already sent a reset. Check your spam folder?"
    end

    it "should respond properly when email doesn't exist" do
      UserMailer.stubs(:reset_password_email).with(anything).returns(@mock_mailer).never
      post :create, {:user => {:email => "fakewrong@example.com" }, :password_reset => "true"}
      assert_redirected_to login_path
      assert_equal flash[:notice], "Sorry, couldn't find that email."
    end

  end

end

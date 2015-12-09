require 'test_helper'

class DocsControllerTest < ActionController::TestCase
  describe "while unauthenticated" do
    test "should be redirected to login" do
      get :index
      assert_redirected_to login_path
    end
  end

  describe "while authenticated" do
    let(:user) { FactoryGirl.create(:user) }
    
    test "should render the page" do
      User.any_instance.stubs(:agent_token).returns("1234")

      login_user(user)
      
      get :index
      assert_response :success
      assert assigns(:user)
    end
  end

end

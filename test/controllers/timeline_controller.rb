require 'test_helper'

class TimelineControllerTest < ActionController::TestCase
  describe "while authenticated" do
    let(:user) { FactoryGirl.create(:user) }
    it "should get index" do
      login_user(user)
      get :index, :format => :json
      assert_response :success
    end
  end

  describe "while unauthenticated" do
    it "should fail to get index" do
      get :index
      assert_redirected_to login_path
    end
  end
end

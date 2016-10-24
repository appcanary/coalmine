require 'test_helper'

class VulnsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  setup do
    vulnerability = FactoryGirl.create(:vulnerability, :id => 1234)
  end

  it "should display the index page" do
    get :index
    assert_response :success
  end

  describe "while unauthenticated" do
    it "should display the page sucessfully" do
      get :show, :id => 1234
      assert_response :success
    end
  end

  describe "while authenticated" do
    it "should display the page successfully" do
      login_user(user)
      get :show, :id => 1234
      assert_response :success
    end
  end
end

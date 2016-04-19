require 'test_helper'

class VulnsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  describe "while unauthenticated" do
    it "should display the page sucessfully" do
      vulnerability = FactoryGirl.create(:vulnerability)
      Vulnerability.expects(:find).with("1234").returns(vulnerability)
      get :show, :id => 1234
      assert_response :success
    end
  end

  describe "while authenticated" do
    it "should display the page successfully" do

      login_user(user)
      vulnerability = FactoryGirl.create(:vulnerability)
      Vulnerability.expects(:find).with("1234").returns(vulnerability)
      get :show, :id => 1234
      assert_response :success
    end
  end
end

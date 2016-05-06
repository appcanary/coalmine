require 'test_helper'

class MonitorsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:monitor) { FactoryGirl.build(:moniter) }

  before(:suite) do
    Moniter.stubs(:find).with(anything, anything).returns(monitor)
  end


  describe "while authenticated" do
    setup do
      login_user(user)
    end

    it "should show the show page" do
      get :show, :id => "1234"
      assert_response :success
    end

    it "should redirect to dashboard on destroy" do
      Moniter.expects(:destroy).with(user, "1234").returns(true)

      delete :destroy, :id => "1234"
      assert_response :redirect
    end
  end

  describe "while unauthenticated" do
    it "show should be redirected" do
      get :show, :id => "1234"
      assert_response :redirect
    end

    it "delete should be redirected" do
      delete :destroy, :id => "1234"
      assert_response :redirect
    end

  end

end

require 'test_helper'

class GreatReviewControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    # assert_response :redirect
    # we removed the login redirect for now
    assert_response :success
  end

end

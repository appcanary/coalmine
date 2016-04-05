require 'test_helper'

class DocsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }

  test "should render the page" do
    User.any_instance.stubs(:agent_token).returns("1234")

    login_user(user)

    get :index
    assert_response :success
    assert assigns(:user)
  end

end

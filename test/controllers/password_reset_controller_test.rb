require 'test_helper'

class PasswordResetControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  before do
    user.generate_reset_password_token!
  end

  test "should display the password reset page" do
    get :show, :id => user.reset_password_token
    assert_response :success
    assert assigns(:user)
    assert_equal assigns(:user).id, user.id
  end

  test "should redirect if reset not valid" do
    get :show, :id => "some bullshit string"
    assert_redirected_to login_path
  end


  test "should update pw properly" do
    put :update, :id => user.reset_password_token, :user => { :password => "12345678",
                                                              :password_confirmation => "12345678"}

    assert_redirected_to login_path
    assert_equal flash[:notice], 'Password was successfully updated.'

    user.reload
    assert_nil user.reset_password_token
  end


  test "should not update pw if pw conf is wrong " do
    put :update, :id => user.reset_password_token, :user => { :password => "12345678",
                                                              :password_confirmation => "1234567"}

    assert_response :success
    assert assigns(:user).errors.present?
  end


end

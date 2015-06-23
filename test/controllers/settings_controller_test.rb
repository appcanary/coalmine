require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }

  it "user should be able to change their password" do
    login_user(user)
    new_pw = "12345678"

    assert_not_nil @controller.send(:login, user.email, TestValues::PASSWORD)

    post :update, :user => { :password => new_pw,
                             :password_confirmation => new_pw}

    assert_nil  @controller.send(:login, user.email, TestValues::PASSWORD)
    assert_not_nil  @controller.send(:login, user.email, new_pw)
  end
end

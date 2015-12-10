require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  let(:user) { FactoryGirl.create(:user) }
  test "reset password email" do
    user.generate_reset_password_token!
    mail = UserMailer.reset_password_email(user)

    assert(mail.body.encoded.match(Rails.application.routes.url_helpers.password_reset_path(:id => user.reset_password_token)), "the correct link is used")
  end
end

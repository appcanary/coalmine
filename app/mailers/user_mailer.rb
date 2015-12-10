class UserMailer < ApplicationMailer
  default from: "Appcanary Support <support@appcanary.com>"
  layout 'mailer'

  def reset_password_email(user)
    @user = user
    @link = password_reset_url(:id => @user.reset_password_token)
    mail(to: user.email, :subject => "Appcanary Password Reset")
  end
end

class SystemMailer < ActionMailer::Base
  default from: "noreply@appcanary.com"
  layout "mailer"

  def new_subscription_email(user_id)
    @user = User.where(id: user_id).first
    if @user.nil?
      return
    end

    mail(to: "hello@appcanary.com", :subject => "Subscription added by #{@user.email}")
  end

  def canceled_subscription_email(user_id)
    @user = User.where(id: user_id).first
    if @user.nil?
      return
    end

    mail(to: "hello@appcanary.com", :subject => "Subscription canceled by #{@user.email}", :body => "")
  end

end

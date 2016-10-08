class NotificationMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def vulnerable_email(msg)
    query = VulnQuery.from_vuln_notifications(msg.notifications)
    @notifier = NotificationPresenter.new(:vuln, msg.account, query)


    mail(to: @notifier.recipients, :subject => @notifier.subject) do |format|
      format.html { render layout: "vulnerable_header" }
      format.text
    end
  end

  def patched_email(msg)
    query = VulnQuery.from_patched_notifications(msg.notifications)
    @notifier = NotificationPresenter.new(:patched, msg.account, query)


    mail(to: @notifier.recipients, :subject => @notifier.subject) do |format|
      format.html { render layout: "patched_header" }
      format.text
    end
  end

end


class NotificationMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'

  def vulnerable_email(msg)
    @notifications = VulnQuery.from_vuln_notifications(msg.notifications)
    @notifications_by_vuln = @notifications.group_by(&:vulnerability)
    mail(to: "hello@appcanary.com", :subject => "Appcanary U R VULN LOL")
  end

  def patched_email(msg)
    @notifications = VulnQuery.from_patched_notifications(msg.notifications)
    @notifications_by_vuln = @notifications.group_by(&:vulnerability)
    mail(to: "hello@appcanary.com", :subject => "Appcanary Patched!")
  end

end


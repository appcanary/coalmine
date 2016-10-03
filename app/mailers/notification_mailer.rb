class NotificationMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def vulnerable_email(msg)
    @notifications = VulnQuery.from_vuln_notifications(msg.notifications)
    @notifications_by_vuln = @notifications.group_by(&:vulnerability)

    recipient = nil
    date_str = Time.now.strftime("%Y-%m-%d")
    subject = "#{@notifications_by_vuln.count} vulnerabilities detected (#{date_str})"
    if Rails.env.production?
      recipient = msg.account.email
    else
      recipient = "hello@appcanary.com"

      if PREPROD_EMAILS.include?(msg.account.email)
        recipient = msg.account.email
      end
      subject = "[#{Rails.env}] " + subject
    end

    mail(to: recipient, :subject => subject) do |format|
      format.html { render layout: "vulnerable_header" }
      format.text
    end
  end

  def patched_email(msg)
    @notifications = VulnQuery.from_patched_notifications(msg.notifications)
    @notifications_by_vuln = @notifications.group_by(&:vulnerability)

    recipient = nil
    date_str = Time.now.strftime("%Y-%m-%d")
    subject = "Fixed: #{@notifications_by_vuln.count} vulnerabilities patched (#{date_str})"
    if Rails.env.production?
      recipient = msg.account.email
    else
      recipient = "hello@appcanary.com"

      if PREPROD_EMAILS.include?(msg.account.email)
        recipient = msg.account.email
      end
      subject = "[#{Rails.env}] " + subject
    end

    mail(to: recipient, :subject => subject) do |format|
      format.html { render layout: "patched_header" }
      format.text
    end
  end

end


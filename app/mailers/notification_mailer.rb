class NotificationMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def vulnerable_email(msg)
    @notifier = NotificationPresenter.new(msg)

    $analytics.track_notification(msg.account, :vuln)

    mail(to: @notifier.recipients, :subject => @notifier.subject) do |format|
      format.html { render layout: "vulnerable_header" }
      format.text
    end
  end

  def patched_email(msg)
    @notifier = NotificationPresenter.new(msg)

    $analytics.track_notification(msg.account, :patched)

    mail(to: @notifier.recipients, :subject => @notifier.subject) do |format|
      format.html { render layout: "patched_header" }
      format.text
    end
  end

end


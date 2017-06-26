class NotificationMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def vulnerable_email(msg)
    @notifier = NotificationEmailPresenter.new(msg)

    $analytics.track_notification(msg.account, :vuln)

    if @notifier.should_deliver?
      mail(to: @notifier.recipients, :subject => @notifier.subject) do |format|
        format.html
        format.text
      end
    end
  end

  def patched_email(msg)
    @notifier = NotificationEmailPresenter.new(msg)

    $analytics.track_notification(msg.account, :patched)

    if @notifier.should_deliver?
      mail(to: @notifier.recipients, :subject => @notifier.subject) do |format|
        format.html
        format.text
      end
    end
  end

end


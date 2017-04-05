class DailySummaryMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def daily_summary(presenter)
    @presenter = presenter
    @date = @presenter.date
    @account = @presenter.account

    @motds = Motd.where("remove_at >= ?", @date)

    if should_deliver?(@account)
      mail(to: @presenter.recipients, :subject => @presenter.subject) do |format|
        format.html
        format.text
      end
    end
  end

  def should_deliver?(account)
    Rails.env.production? || $rollout.active?(:all_staging_notifications) || account.email == "hello@appcanary.com"
  end
end

class DailySummaryMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def daily_summary(account_id, date)
    @date = date.to_date
    @account = Account.find(account_id)

    @motds = Motd.where("remove_at >= ?", @date)
    @presenter = DailySummaryQuery.new(@account, @date).create_presenter

    if should_deliver?(@account)
      mail(to: @presenter.recipients, :subject => @presenter.subject) do |format|
        format.html
        format.text
      end
    end
  end

  def self.send_daily_report!
    self.daily_summary(22, Date.yesterday).deliver_now
    self.daily_summary(493, Date.yesterday).deliver_now
  end

  def should_deliver?(account)
    if Rails.env.production? && $rollout.active?(:daily_summary, @account)
      return true
    elsif $rollout.active?(:all_staging_notifications)
      return true
    else
      if account.email == "hello@appcanary.com"
        return true
      else
        return false
      end
    end
  end
end

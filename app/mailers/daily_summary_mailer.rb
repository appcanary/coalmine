class DailySummaryMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def daily_summary(account_id, date = "2017-01-31")
    @date = date.to_date
    @account = Account.find(account_id)

    @motds = Motd.where("remove_at >= ?", @date)
    @presenter = DailySummaryManager.new(@account, @date).create_presenter

    mail(to: "phillmv@appcanary.com", :subject => "daily summary lol") do |format|
        format.html
        format.text
    end
  end
end

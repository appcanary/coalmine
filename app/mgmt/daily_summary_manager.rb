class DailySummaryManager
  def self.send_todays_summary!
    date = Date.yesterday

    accts = accounts_that_want_summaries(date).select(:id)

    accts.find_each do |acct|
      if acct.has_activity?
        msg = DailySummaryMailer.daily_summary(acct.id, date)

        if msg
          EmailDailySummary.create!(:account_id => acct.id, 
                                    :report_date => date,
                                    :recipients => msg.to,
                                    :sent_at => msg.date)
          msg.deliver_now!
        end
      end

    end
  end

  def self.accounts_that_want_summaries(date)
    daily_users = User.where(:pref_email_frequency => PrefOpt::EMAIL_WANTS_DAILY)
    sent_emails = EmailDailySummary.where("report_date = ?", date)

    Account.where(id: daily_users.select(:account_id)).
      where.not(id: sent_emails.select(:account_id))
  end
end

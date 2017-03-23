class DailySummaryManager
  def self.send_todays_summary!
    date = Date.yesterday

    accts = accounts_that_want_summaries(date).select(:id)

    accts.find_each do |acct|
      if acct.has_activity?
        msg = DailySummaryMailer.daily_summary(acct.id, date).deliver_now!

        if msg
          EmailDailySummary.create!(:account_id => acct.id, 
                                    :report_date => date,
                                    :recipients => msg.to,
                                    :sent_at => msg.date)
        end
      end

    end
  end

  def self.accounts_that_want_summaries(date)

    Account.joins(:users).
      # we left join on email messages that either
      # do not have a report_date or the report_date
      # matches this date. 
      # LEFT JOIN because we want to filter them out
      joins("LEFT JOIN email_messages ON 
            accounts.id = email_messages.account_id AND 
            email_messages.type = 'EmailDailySummary'").
      # whose user pref says they want DS
      where(users: { :pref_email_frequency => PrefOpt::EMAIL_WANTS_DAILY}).
      # and where there is no corresponding EmailDailySummary
      # for this date in particular
      where("email_messages.report_date IS NULL OR 
            email_messages.report_date != ?", date)

  end
end

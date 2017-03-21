class DailySummaryManager
  def self.send_todays_summary!
    date = Date.yesterday

    accts = accounts_that_want_summaries(date).select(:id)

      accts.find_each do |acct|
          DailySummaryMailer.daily_summary(acct.id, date).deliver_now!
          email = EmailDailySummary.create!(:account_id => account_id,
                                            :report_date => date)
      end
  end

  def self.accounts_that_want_summaries(date)

    # give me all accounts
    Account.joins(:users).
      joins("LEFT JOIN email_messages ON 
            accounts.id = email_messages.account_id AND 
            email_messages.type = 'EmailDailySummary'").
      # whose user pref says they want DS
      # TODO: remove magic string
      where(users: { :pref_email_frequency => PrefOpt::EMAIL_WANTS_DAILY}).
      # and where there is no corresponding EmailDailySummary
      # for this date in particular
      where("email_messages.report_date IS NULL OR 
            email_messages.report_date != ?", date)

  end
end

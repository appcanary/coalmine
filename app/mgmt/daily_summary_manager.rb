class DailySummaryManager
  def self.send_todays_summary!(date = Date.yesterday)
    accts = accounts_that_want_summaries(date)

    accts.find_each do |acct|
      if acct.has_activity?

        presenter = DailySummaryQuery.new(acct, date).create_presenter

        # Only send when there are vulns or patches for users that want that
        # NOTE: This relies on accounts being 1-1 with user since emails prefs
        # are on users while daily summaries are sent to accounts.
        # TODO: refactor when we add multiple users per account (loop should be changed anyway to not generate once per user)
        pref = acct.users.first.pref_email_frequency

        if pref != PrefOpt::EMAIL_FREQ_DAILY_WHEN_VULN ||
           (pref == PrefOpt::EMAIL_FREQ_DAILY_WHEN_VULN && presenter.has_vulns_servers_to_report?)
          msg = DailySummaryMailer.daily_summary(presenter)

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
  end

  def self.accounts_that_want_summaries(date)
    daily_users = User.where(:pref_email_frequency => PrefOpt::EMAIL_WANTS_DAILY)
    sent_emails = EmailDailySummary.where("report_date = ?", date)

    Account.where(id: daily_users.select(:account_id)).
      where.not(id: sent_emails.select(:account_id))
  end
end

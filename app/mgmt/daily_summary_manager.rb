class DailySummaryManager
  def self.send_todays_summary!(date = Date.yesterday)
    accts = accounts_that_want_summaries(date)

    accts.find_each do |acct|
      # If one of these errors out, we still want to send the rest.
      # This will send the error to sentry and carry on
      begin
        if acct.has_activity?
          presenter = DailySummaryQuery.new(acct, date).create_presenter
          if acct.wants_daily_summary?(presenter.has_vulns_or_servers_to_report?)
            msg = DailySummaryMailer.daily_summary(presenter).deliver_now!

            if msg
              EmailDailySummary.create!(:account_id => acct.id,
                                        :report_date => date,
                                        :recipients => msg.to,
                                        :sent_at => msg.date)
            end
          end
        end
      rescue Exception => e
        Raven.capture_exception(e)
        # Normally we want to swallow this exception since we're running this in a task and we'll get in Sentry, but in dev and test I actually want to be alerted to it
        if Rails.env.test? || Rails.env.development?
          raise e
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

  def self.regenerate(aid, date)
    acct = Account.find(aid)
    p = DailySummaryQuery.new(acct, date).create_presenter
    DailySummaryMailer.daily_summary(p).deliver_now!
  end
end

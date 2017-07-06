class DailySummaryManager
  attr_accessor :account, :date

  def initialize(account, date)
    self.account = account
    self.date = date
  end

  def sort_group_log_vulns(query)
    query.group_by(&:vulnerability).
      reduce({}) { |hsh, (vuln, logs)|
      hsh[vuln] = logs.map(&:package_id).uniq
      hsh

    }.sort_by { |vuln, pkgs|
      [-vuln.criticality_ordinal, -pkgs.size]
    }.map { |vuln, pkgs|
      [vuln.id, pkgs]
    }
  end

  def make_summary
    dsq = DailySummaryQuery.new(self.account, self.date)
    hsh = {
      account_id: self.account.id,
      date: self.date,

      all_vuln_ct: dsq.all_vuln_ct,

      all_server_ids: dsq.all_servers.pluck(:id),
      new_server_ids: dsq.new_servers.pluck(:id),
      deleted_server_ids: dsq.deleted_servers.pluck(:id),

      active_server_count: dsq.all_servers.active_as_of(self.date).count,

      all_monitor_ids: dsq.all_monitors.pluck(:id),
      new_monitor_ids: dsq.new_monitors.pluck(:id),
      deleted_monitor_ids: dsq.deleted_monitors.pluck(:id),

      changes_server_count: dsq.changes[:server_ct],
      changes_monitor_count: dsq.changes[:monitor_ct],
      changes_added_count: dsq.changes[:added_ct],
      changes_removed_count: dsq.changes[:removed_ct],
      changes_upgraded_count: dsq.changes[:upgraded_ct]
    }

    ["fresh_vulns", "new_vulns", "patched_vulns", "cantfix_vulns"].each do |k|
      hsh[(k + "_vuln_pkg_ids").to_sym] = sort_group_log_vulns(dsq.send(k)).to_json
      hsh[(k + "_server_ids").to_sym] = dsq.send(k).pluck(:agent_server_id).select(&:present?).uniq
      hsh[(k + "_monitor_ids").to_sym] = dsq.send(k).select{|lbv| lbv.agent_server_id.nil?}.map(&:bundle_id).uniq
      hsh[(k + "_package_ids").to_sym] = dsq.send(k).pluck(:package_id).uniq
      hsh[(k + "_supplementary_count").to_sym] = dsq.send(k).select(&:supplementary).map(&:vulnerability_id).uniq.size
    end

    DailySummary.new(hsh)
  end

  def create_summary!
    s = self.make_summary
    s.save!
    s
  end

  def send_summary
    # If one of these errors out, we still want to send the rest.
    # This will send the error to sentry and carry on
    if self.account.has_activity?
      # Create the daily summary if it doesn't exist
      unless ds = DailySummary.where(account: self.account, date: self.date).take
        ds = self.create_summary!
      end
      presenter = DailySummaryPresenter.new(ds)
      if self.account.wants_daily_summary?(presenter.has_vulns_or_servers_to_report?)
        msg = DailySummaryMailer.daily_summary(presenter).deliver_now!

        if msg
          EmailDailySummary.create!(:account_id => self.account.id,
                                    :report_date => self.date,
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

  def self.send_todays_summaries!(date = Date.yesterday)
    accts = accounts_that_want_summaries(date)

    accts.find_each do |acct|
      self.new(acct, date).send_summary
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

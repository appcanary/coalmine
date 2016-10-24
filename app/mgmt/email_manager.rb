class EmailManager < ServiceManager
  def self.queue_and_send_vuln_emails!
    # TODO: ensure this call groups them by day / hour or some time period?
    # this could theoretically create an email per notification generated,
    # if the query is run frequently enough.
    
    queue_vuln_emails!
    send_vuln_emails!
  end

  def self.queue_vuln_emails!
    self.queue_emails!(EmailVulnerable, LogBundleVulnerability, :log_bundle_vulnerability_id)
  end

  def self.send_vuln_emails!
    send_new_emails(EmailVulnerable, :vulnerable_email)
  end

  def self.queue_and_send_patched_emails!
    queue_patched_emails!
    send_patched_emails!
  end

  def self.queue_patched_emails!
    queue_emails!(EmailPatched, LogBundlePatch, :log_bundle_patch_id)
  end

  def self.send_patched_emails!
    send_new_emails(EmailPatched, :patched_email)
  end


  # takes the log class that it slurps logs from
  # the email class it will create messages on
  # and the foreign key it needs to set accordingly
  def self.queue_emails!(emailklass, logklass, fkey)
    EmailMessage.transaction do
      account_and_lbvs = logklass.unnotified_logs_by_account
      logs_by_account = group_by_account(account_and_lbvs)

      logs_by_account.each_pair do |aid, logs|

        # not every log is immediately notifiable
        notifiable_logs = filter_logs(logs, logklass)

        # only create an email if we have anything to notify
        if notifiable_logs.present?
          email = emailklass.create!(:account_id => aid)

          notifiable_logs.each do |lid|
            Notification.create!(:email_message_id => email.id,
                                 fkey => lid)
          end
        end

      end
    end
  end
   
  def self.send_new_emails(klass, sym)
    klass.transaction do
      klass.unsent.find_each do |msg|
        # uhm, should requeue if email fails no?
        unless $rollout.active?(:skip_notifications)
          NotificationMailer.send(sym, msg).deliver_now
        end
        msg.update(sent_at: Time.now)
      end
    end
  end

  # purpose of this method is to ditch logs that don't have patches
  # we select by (&:vuln_dep) to filter out any logs which
  # have since been edited upstream and are now irrelevant
  # TODO: handle LBVs that point to since-deleted vuln_deps
  def self.filter_logs(logs, klass)
    klass.includes(:vulnerable_dependency).find(logs).
      select(&:vulnerable_dependency).select { |lbv|
      lbv.vulnerable_dependency.patcheable?
    }.map(&:id)
  end

  def self.group_by_account(arr)
    arr.reduce({}) { |hsh, (a_id, lbv)|
        hsh[a_id] ||= []
        hsh[a_id] << lbv
        hsh
      }
  end
end

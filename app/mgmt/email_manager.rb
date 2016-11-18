# EmailManager finds accounts that might deserve an email
# and then checks to see if they do in fact want to receive one.
#
# By this I mean, we first look up the universe of users that have
# logs that were never notified, and then we iterate over every
# user and see if they actually care about these logs.
#
# Each Account has specific needs. Maybe you want to receive every
# and all notifications. We need to make decisions per account.

class EmailManager

  def self.queue_and_send_vuln_emails!
    # TODO: ensure this call groups them by day / hour or some time period?
    # this could theoretically create an email per notification generated,
    # if the query is run frequently enough.
    
    queue_vuln_emails!
    send_vuln_emails!
  end

 
  def self.queue_and_send_patched_emails!
    queue_patched_emails!
    send_patched_emails!
  end


  def self.queue_vuln_emails!
    accounts = Account.with_unnotified_vuln_logs

    accounts.select do |acct|
      self.create_vuln_email!(acct)
    end
  end

   def self.queue_patched_emails!
    accounts = Account.with_unnotified_patch_logs

    accounts.select do |acct|
      self.create_patched_email!(acct)
    end
  end


  def self.create_vuln_email!(acct)
    EmailMessage.transaction do
      unnotified_logs = VulnQuery.new(acct).unnotified_vuln_logs

      # TODO: perform checks like, has it been long enough
      # since the last email?
      # or, has this notification been patched?

      if unnotified_logs.any?
        email = EmailVulnerable.create!(:account => acct)

        unnotified_logs.pluck(:id).each do |lid|
          Notification.create!(:email_message_id => email.id,
                               :log_bundle_vulnerability_id => lid)
        end
      else
        nil
      end
    end
  end


  def self.create_patched_email!(acct)
    EmailMessage.transaction do
      unnotified_logs = VulnQuery.new(acct).unnotified_patch_logs

      # TODO: perform checks like, has it been long enough
      # since the last email?
      # or, are you still vulnerable?

      if unnotified_logs.any?
        email = EmailPatched.create!(:account => acct)

        unnotified_logs.pluck(:id).each do |lid|
          Notification.create!(:email_message_id => email.id,
                               :log_bundle_patch_id => lid)
        end
      else
        nil
      end
    end
  end


  def self.send_vuln_emails!
    send_new_emails(EmailVulnerable, :vulnerable_email)
  end

  def self.send_patched_emails!
    send_new_emails(EmailPatched, :patched_email)
  end
   
  def self.send_new_emails(klass, sym)
    unless $rollout.active?(:stop_email)
      klass.transaction do
        klass.unsent.find_each do |msg|
          unless $rollout.active?(:skip_notifications)
            NotificationMailer.send(sym, msg).deliver_now
          end
          msg.update(sent_at: Time.now)
        end
      end
    end
  end

end

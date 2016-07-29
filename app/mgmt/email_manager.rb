class EmailManager < ServiceManager
  def self.queue_and_send_vuln_emails!
    EmailMessage.transaction do
      account_and_lbvs = LogBundleVulnerability.unnotified_logs_by_account.pluck("account_id, log_bundle_vulnerability_id")

      emails_to_q = group_and_arrange(account_and_lbvs)

      emails_to_q.each_pair do |aid, lbvs|
        email = EmailVulnerable.create!(:account_id => aid)

        lbvs.each do |lid|
          Notification.create!(:email_message_id => email.id,
                               :log_bundle_vulnerability_id => lid)
        end

        email
      end
    end

    send_new_emails(EmailVulnerable)
  end

  def self.queue_and_send_patched_emails!
    EmailMessage.transaction do
      account_and_lbps = LogBundlePatch.unnotified_logs_by_account.pluck("account_id, log_bundle_patch_id")

      emails_to_q = group_and_arrange(account_and_lbps)

      emails_to_q.each_pair do |aid, lbps|
        email = EmailPatch.create!(:account_id => aid)

        lbvs.each do |lid|
          Notification.create!(:email_message_id => email.id,
                               :log_bundle_patch_id => lid)
        end

        email
      end
    end

    send_new_emails(EmailPatch)
  end

  def self.send_new_emails(klass)
    klass.transaction do
      klass.unsent.find_each do |email|
        ## TODO
      end
    end
  end

  def self.group_and_arrange(arr)
    arr.reduce({}) { |hsh, (a_id, lbv)|
        hsh[a_id] ||= []
        hsh[a_id] << lbv
        hsh
      }
  end
end

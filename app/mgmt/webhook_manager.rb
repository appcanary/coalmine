class WebhookManager
  def self.queue_and_send_vuln_webhooks!
    queue_vuln_webhooks!
    send_vuln_webhooks!
  end

  def self.queue_and_send_patched_webhooks!
    queue_patched_webhooks!
    send_patched_webhooks!
  end

  def self.queue_vuln_webhooks!
    accounts = Account.with_unwebhooked_vuln_logs.joins(:webhook)

    accounts.select do |acct|
      self.create_vuln_webhook_message!(acct)
    end
  end

   def self.queue_patched_webhooks!
     accounts = Account.with_unwebhooked_patch_logs.joins(:webhook)

     accounts.select do |acct|
       self.create_patched_webhook_message!(acct)
     end
  end

  def self.create_vuln_webhook_message!(acct)
    WebhookMessage.transaction do
      unwebhooked_logs = VulnQuery.new(acct).unwebhooked_vuln_logs.where("log_bundle_vulnerabilities.created_at >= ? ", 2.days.ago)
      # TODO: possibly unify this logic with the email manager that does basically the same thing
      if unwebhooked_logs.any?
        whm = WebhookVulnerable.create!(:account => acct,
                                     :webhook => acct.webhook,
                                     :url => acct.webhook.url)


        unwebhooked_logs.pluck(:id).each do |lid|
          Notification.create!(:webhook_message_id => whm.id,
                               :log_bundle_vulnerability_id => lid)
        end
      else
        nil
      end
    end
  end

  def self.create_patched_webhook_message!(acct)
    WebhookMessage.transaction do
      unwebhooked_logs = VulnQuery.new(acct).unwebhooked_patch_logs.where("log_bundle_patches.created_at >= ? ", 20.days.ago)
      if unwebhooked_logs.any?
        whm = WebhookPatched.create!(:account => acct,
                                     :webhook => acct.webhook,
                                     :url => acct.webhook.url)

        unwebhooked_logs.pluck(:id).each do |lid|
          Notification.create!(:webhook_message_id => whm.id,
                               :log_bundle_patch_id => lid)
        end
      else
        nil
      end
    end
  end

  def self.send_patched_webhooks!
    unless $rollout.active?(:stop_webhooks)
      WebhookPatched.unsent.find_each do |whm|
        WebhookPatched.transaction do
          data = SlackWebhookPatchedSerializer.new(whm)
          RestClient.post(whm.webhook.url, data.to_json)
        end
      end
    end
  end

  def self.send_vuln_webhooks!
    #send_new_webhook_messages(Em)
  end
end

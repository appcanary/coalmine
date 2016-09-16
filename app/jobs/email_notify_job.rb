class EmailNotifyJob < CronJob
  INTERVAL = 5.minutes

  def run(args)
    log "Compiling and sending vuln emails"
    EmailManager.queue_and_send_vuln_emails!
    log "Compiling and sending patched emails"
    EmailManager.queue_and_send_patched_emails!
  end
end

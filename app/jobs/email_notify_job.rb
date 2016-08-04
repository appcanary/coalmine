class EmailNotifyJob < CronJob
  INTERVAL = 5.minutes

  def self.enqueue_if_not_existing!
    unless QueJob.where(:job_class => "EmailNotifyJob").count > 0 
      t_end = Time.now
      t0 = t_end - INTERVAL
      EmailNotifyJob.enqueue :start_at => t0.to_f, :end_at => t_end.to_f
    end
  end

  def run(args)
    EmailManager.queue_and_send_vuln_emails!
    EmailManager.queue_and_send_patched_emails!
  end
end

class AdvisoryImportJob < CronJob
  INTERVAL = 5.minutes

  def self.enqueue_if_not_existing!
     unless QueJob.where(:job_class => "AdvisoryImportJob").count > 0 
      t_end = Time.now
      t0 = t_end - INTERVAL
      self.enqueue :start_at => t0.to_f, :end_at => t_end.to_f
    end
  end

  def run(args)
    AdvisoryManager.import!
  end
end

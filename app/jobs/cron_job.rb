class CronJob < Jobber
  # Default repetition interval in seconds. Can be overridden in
  # subclasses. Can use 1.minute if using Rails.
  INTERVAL = 60

  attr_reader :start_at, :end_at, :run_again_at, :time_range

  def self.enqueue_if_not_existing!
    unless QueJob.where(:job_class => self.name).count > 0 
      t_end = Time.now
      t0 = t_end - self::INTERVAL
      self.enqueue :start_at => t0.to_f, :end_at => t_end.to_f
    end
  end

  def _run
    log "Starting..."
    args = attrs[:args].first
    @start_at, @end_at = Time.at(args.delete('start_at')), Time.at(args.delete('end_at'))
    @run_again_at = @end_at + self.class::INTERVAL
    @time_range = @start_at...@end_at

    super
    log "Done."

    args['start_at'] = @end_at.to_f
    args['end_at']   = @run_again_at.to_f
    self.class.enqueue(args, run_at: @run_again_at)
  end
end

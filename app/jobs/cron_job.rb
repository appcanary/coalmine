class CronJob < Que::Job
  # Default repetition interval in seconds. Can be overridden in
  # subclasses. Can use 1.minute if using Rails.
  INTERVAL = 60

  attr_reader :start_at, :end_at, :run_again_at, :time_range

  def _run
    args = attrs[:args].first
    @start_at, @end_at = Time.at(args.delete('start_at')), Time.at(args.delete('end_at'))
    @run_again_at = @end_at + self.class::INTERVAL
    @time_range = @start_at...@end_at

    super

    args['start_at'] = @end_at.to_f
    args['end_at']   = @run_again_at.to_f
    self.class.enqueue(args, run_at: @run_again_at)
  end
end

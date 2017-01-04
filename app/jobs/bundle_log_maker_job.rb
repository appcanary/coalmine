class BundleLogMakerJob < Jobber
  @queue = "log_maker"
  def run(bundle_id)
    Bundle.transaction do
      lm = LogMaker.new(bundle_id: bundle_id)
      lm.make_logs!
      lm.bundle.mark_processed!
      destroy
    end
  end
end

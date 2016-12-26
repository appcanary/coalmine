class LogMakerJob < CronJob
  #I actually want this to be running almost continuously
  INTERVAL = 1.minutes

  def run(args = nil)
    # First create all the logs for any updated bundles
    Bundle.unprocessed.find_each do |bundle|
      Bundle.transaction do
        lm = LogMaker.new
        lm.on_bundle_change(bundle.id)
        bundle.mark_processed!
      end
    end

    # No we create all the logs for any updated vulns
    Vulnerability.unprocessed.find_each do |vuln|
      Vulnerability.transaction do
        lm = LogMaker.new
        lm.on_vulnerability_change(vuln.id)
        vuln.mark_processed!
      end
    end
  end
end

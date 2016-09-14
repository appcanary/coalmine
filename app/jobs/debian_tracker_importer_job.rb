class DebianTrackerImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    ct = DebianTrackerImporter.new.import!
    log "Handled #{ct.size} advisories."
  end
end

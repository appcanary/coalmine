class UbuntuTrackerImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    ct = UbuntuTrackerImporter.new.import!
    log "Handled #{ct.size} advisories."
  end
end

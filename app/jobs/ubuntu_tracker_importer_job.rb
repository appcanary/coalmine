class UbuntuTrackerImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    UbuntuTrackerImporter.new.import!
  end
end

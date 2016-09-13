class UbuntuTrackerImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    UbuntuTrackerImporter.new.import!
  end
end

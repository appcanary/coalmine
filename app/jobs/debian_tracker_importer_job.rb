class DebianTrackerImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    DebianTrackerImporter.new.import!
  end
end

class DebianTrackerImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    DebianTrackerImporter.new.import!
  end
end

class AlasImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    AlasImporter.new.import!
  end
end

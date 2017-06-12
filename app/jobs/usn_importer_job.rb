class UsnImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    UsnImporter.new.import!
  end
end

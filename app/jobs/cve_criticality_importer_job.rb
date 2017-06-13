class CveCriticalityImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    CveCriticalityImporter.new.import!
  end
end

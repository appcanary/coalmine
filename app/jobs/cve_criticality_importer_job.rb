class CveCriticalityImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    CveCriticalityImporter.import_criticalities
  end
end

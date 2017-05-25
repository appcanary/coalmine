class UsnReferenceImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    UsnReferenceImporter.import_references
  end
end

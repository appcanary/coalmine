class CesaDescriptionImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    CesaDescriptionImporter.import_descriptions
  end
end

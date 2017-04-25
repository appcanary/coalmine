class CesaDescriptionImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    CesaDescriptionImporter.new.import_descriptions
  end
end

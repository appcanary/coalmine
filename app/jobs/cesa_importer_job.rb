class CesaImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    CesaImporter.new.import!
  end
end

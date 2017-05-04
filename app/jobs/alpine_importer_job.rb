class AlpineImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    AlpineImporter.new.import!
  end
end

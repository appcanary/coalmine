class AlasImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    AlasImporter.new.import!
  end
end

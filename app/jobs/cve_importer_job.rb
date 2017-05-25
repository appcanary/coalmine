class CveImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    CveImporter.new.import!
  end
end

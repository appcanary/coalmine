class RHSAImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    RHSAImporter.new.import!
  end
end

class RubysecImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    RubysecImporter.new.import!
  end
end

class RubysecImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    RubysecImporter.new.import!
  end
end

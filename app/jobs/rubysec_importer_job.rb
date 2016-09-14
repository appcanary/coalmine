class RubysecImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
    ct = RubysecImporter.new.import!
    log "Handled #{ct.size} advisories."
  end
end

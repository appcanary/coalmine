class AlasImporterJob < CronJob
  INTERVAL = 1.hour

  def run(args)
   ct = AlasImporter.new.import!
   log "Handled #{ct.size} advisories."
  end
end

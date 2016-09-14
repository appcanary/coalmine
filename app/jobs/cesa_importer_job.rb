class CesaImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    ct = CesaImporter.new.import!
    log "Handled #{ct.size} advisories."
  end
end

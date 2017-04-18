class FriendsOfPHPImporterJob < CronJob
  INTERVAL = 1.hour.to_i

  def run(args)
    FriendsOfPHPImporter.new.import!
  end
end

namespace :db do
  desc "one time prod import"
  task :one_time_prod_import => :environment do
    if ENV["FILE"].blank?
      raise ArgumentError.new("You have to specify a FILE env var")
    end

    $rollout.activate(:skip_notifications)

    # julian's distro is just messed up
    skip_user = {"julian.squires@adgear.com" => true}

    raw_file = File.read(ENV["FILE"])
    json = JSON.load(raw_file)
    json.lazy.each do |usr|
      if skip_user[usr["email"]]
        puts "SKIPPING #{usr["email"]}"
        next
      end

      u = User.where(email: usr["email"]).first

      # can't find user? eeeeh fuck it
      unless u
        puts "SKIPPING #{usr["email"]}"
        next
      end
      puts "handling #{usr["email"]}"
      account = u.account

      prod_import = ProdImporter.new(account)
      usr["servers"].each do |srv|

        server = prod_import.create_server(srv)
        srv["apps"].each do |app_hsh|
          prod_import.create_server_bundle(server, app_hsh)
        end
      end

      usr["monitored-apps"].each do |mon_hsh|
        prod_import.create_bundle(mon_hsh)
      end
    end

    # flush out all those pesky email notifications
    # so we can disable skip_notifications
    # obviously, this assumes we already have
    # the vulns all loaded
    EmailManager.queue_and_send_vuln_emails
  end
end

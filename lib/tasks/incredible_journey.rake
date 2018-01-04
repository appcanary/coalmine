namespace :incredible do
  namespace :journey do
    task :complete => :environment do
      puts "Completing Incredible Journey"
      puts "- disabling signups"
      $rollout.activate(:acquired)
      User.find_each do |user|
        puts "- emailing #{user.email}"
        SystemMailer.acquisition_email(user).deliver_now!
      end
      puts "To the next adventure!"
    end
  end
end

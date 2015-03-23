User.where(:email => 'sama@ycombinator.com').first_or_create(
  :password => "500 startups",
  :password_confirmation => "500 startups")

FactoryGirl.define do
  factory :server do
    uuid { SecureRandom.uuid }
    name { Faker::Internet.domain_word }
    apps { rand(1..5).times.map { FactoryGirl.build(:app) } }
    last_heartbeat_at { rand(1..10).hours.ago }
  end

  factory :app do
    uuid { SecureRandom.uuid }
    path { "/var/www/fake/Gemfile.lock" }
    artifact_versions { [] }
  end

  factory :vulnerability do
    uuid { SecureRandom.uuid }
    description { Faker::Hacker.say_something_smart }
    title { Faker::Lorem.sentence }

    # lol, ApiBase assumes this is all a parsed json hash
    attributes { {"artifact" => 5.times.map { FactoryGirl.build(:artifact).to_h } } }
  end

  factory :artifact_versions do
    vulnerability {
    }

    kind { ["Ruby", "Lol"].sample }
  end

  factory :artifact do
    uuid { SecureRandom.uuid }
    description { Faker::Lorem.sentence }
    kind { ["Ruby", "Lol"].sample }
    name { Faker::Hacker.ingverb }
  end

end


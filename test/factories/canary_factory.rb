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
    factory :vulnerable_app do 
      vulnerable true
      attributes { 
        {
          "vulnerable_artifact_versions" => 5.times.map { FactoryGirl.build(:vulnerable_artifact_version).to_h }
        }
      }
    end
  end

  factory :artifact_version do
    attributes { {
      "name" => Faker::Hacker.ingverb,
      "kind" => ["Ruby", "Ubuntu"].sample } } 
    factory :vulnerable_artifact_version do
      # sigh ApiBase
      vulnerability { 2.times.map { FactoryGirl.build(:vulnerability).to_h } }
    end
  end

  factory :moniter do
    uuid { SecureRandom.uuid }
    name { SecureRandom.uuid }
    path { "/var/www/fake/Gemfile.lock" }
    artifact_versions { [] }
    created_at { 5.minutes.ago }
    vulnerable_versions { [] }
  end


  factory :vulnerability do
    uuid { SecureRandom.uuid }
    description { Faker::Hacker.say_something_smart }
    title { Faker::Lorem.sentence }

    # lol, ApiBase assumes this is all a parsed json hash
    attributes { {"artifact" => 5.times.map { FactoryGirl.build(:artifact).to_h } } }
  end

  factory :artifact do
    uuid { SecureRandom.uuid }
    description { Faker::Lorem.sentence }
    kind { ["Ruby", "Ubuntu"].sample }
    name { Faker::Hacker.ingverb }
  end

end


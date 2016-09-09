require File.join(Rails.root, "test/factories", "factory_helper")

FactoryGirl.define do
  sequence :identifier do |n|
    "ID-#{n}"
  end
  factory :advisory do
    identifier
    trait :ruby do
      package_platform { Platforms::Ruby }
      source "rubysec"
    end
  end
end

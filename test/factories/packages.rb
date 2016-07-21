# == Schema Information
#
# Table name: packages
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  source_name :string
#  platform    :string
#  release     :string
#  version     :string
#  artifact    :string
#  epoch       :string
#  arch        :string
#  filename    :string
#  checksum    :string
#  origin      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  valid_at    :datetime         not null
#  expired_at  :datetime         default("infinity"), not null
#

require File.join(Rails.root, "test/factories", 'factory_helper')

FactoryGirl.define do

  sequence :name do |n|
    "#{Faker::Hacker.ingverb}##{n}"
  end

  factory :package do
    name { generate(:name) }
    version { FactoryHelper.rand_version_str }
    platform { ["ubuntu", "ruby"].sample }

    trait :ubuntu do
      platform "ubuntu"
      release "utopic"
    end

    trait :centos do
      platform "centos"
      release "7"
    end

    trait :ruby do
      platform Platforms::Ruby
    end
  end
end

# == Schema Information
#
# Table name: packages
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  source_name     :string
#  platform        :string
#  release         :string
#  version         :string
#  version_release :string
#  epoch           :string
#  arch            :string
#  filename        :string
#  checksum        :string
#  origin          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  valid_at        :datetime         not null
#  expired_at      :datetime         default("infinity"), not null
#
# Indexes
#
#  index_packages_on_expired_at                                 (expired_at)
#  index_packages_on_name_and_version_and_platform_and_release  (name,version,platform,release)
#  index_packages_on_valid_at                                   (valid_at)
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
# == Schema Information
#
# Table name: packages
#
#  id          :integer          not null, primary key
#  name        :string
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
#
require File.join(Rails.root, "test/factories", 'factory_helper')

FactoryGirl.define do
  factory :package do
    name { Faker::Hacker.ingverb }
    version { FactoryHelper.rand_version_str }
    factory :ubuntu_package do
      platform "ubuntu"
      release "utopic"
    end

    factory :ruby_package do
      platform "ruby"
    end
  end
end

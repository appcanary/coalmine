# == Schema Information
#
# Table name: vulnerable_packages
#
#  id               :integer          not null, primary key
#  package_id       :integer
#  vulnerability_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do

  trait :vulnerable_package_name do
    name { Faker::Hacker.ingverb }
    package_name { name }
  end

  factory :vulnerable_package do
    pkg_name = Faker::Hacker.ingverb
    association :package, name: pkg_name
    association :vulnerability, package_name: pkg_name
  end
end

# == Schema Information
#
# Table name: vulnerable_packages
#
#  id               :integer          not null, primary key
#  package_id       :integer          not null
#  vulnerability_id :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
#

FactoryGirl.define do
  factory :vulnerable_package do
    pkg_name = Faker::Hacker.ingverb
    association :package, name: pkg_name
    association :vulnerability, package_names: [pkg_name]
  end
end

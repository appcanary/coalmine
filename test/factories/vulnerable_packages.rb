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
    transient do
      platform_type { :ruby }
      dep { build(:package, platform_type) }
    end
    # pkg_name = Faker::Hacker.ingverb
    package { dep }
  end
end

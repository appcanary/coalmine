# == Schema Information
#
# Table name: bundles
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string
#  path       :string
#  platform   :string           not null
#  release    :string
#  last_crc   :integer
#  from_api   :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  valid_at   :datetime         not null
#  expired_at :datetime         default("infinity"), not null
#

FactoryGirl.define do
  factory :bundle do
    association :account
    name { Faker::App.name }
    platform { Platforms::Ruby }
    factory :bundle_with_packages do
      platform  { FactoryHelper.rand_platform }
      release "release"

      transient do
        packages_count 5
      end

      after(:create) do |bundle, evaluator|
        bundle.packages = create_list(:package, evaluator.packages_count, 
                                      platform: evaluator.platform, 
                                      release: evaluator.release)
      end

    end
  end
end

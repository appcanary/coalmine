# == Schema Information
#
# Table name: bundles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  path       :string
#  platform   :string
#  release    :string
#  last_crc   :integer
#  from_api   :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


FactoryGirl.define do
  factory :bundle do
    association :account
    name { Faker::App.name }
    factory :bundle_with_packages do
      platform  { FactoryHelper.rand_platform }
      release "release"

      transient do
        packages_count 5
      end

      after(:create) do |bundle, evaluator|
        bundle.packages = create_list(:package, evaluator.packages_count, platform: evaluator.platform, release: evaluator.release)
      end

    end
  end
end

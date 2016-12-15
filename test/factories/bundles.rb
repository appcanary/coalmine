# == Schema Information
#
# Table name: bundles
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  agent_server_id :integer
#  name            :string
#  path            :string
#  platform        :string           not null
#  release         :string
#  last_crc        :integer
#  being_watched   :boolean
#  from_api        :boolean
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  valid_at        :datetime         not null
#  expired_at      :datetime         default("infinity"), not null
#
# Indexes
#
#  index_bundles_on_account_id                               (account_id)
#  index_bundles_on_account_id_and_agent_server_id           (account_id,agent_server_id)
#  index_bundles_on_account_id_and_agent_server_id_and_path  (account_id,agent_server_id,path)
#  index_bundles_on_agent_server_id                          (agent_server_id)
#  index_bundles_on_expired_at                               (expired_at)
#  index_bundles_on_valid_at                                 (valid_at)
#

FactoryGirl.define do
  factory :bundle do
    sequence :name do |n|
      "#{Faker::App.name}#{n}"
    end

    association :account
    platform { Platforms::Ruby }
    factory :bundle_with_packages do
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

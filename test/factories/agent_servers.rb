# == Schema Information
#
# Table name: agent_servers
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  agent_release_id :integer
#  uuid             :uuid
#  hostname         :string
#  uname            :string
#  name             :string
#  ip               :string
#  distro           :string
#  release          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
#
# Indexes
#
#  index_agent_servers_on_account_id        (account_id)
#  index_agent_servers_on_agent_release_id  (agent_release_id)
#  index_agent_servers_on_expired_at        (expired_at)
#  index_agent_servers_on_uuid              (uuid)
#  index_agent_servers_on_valid_at          (valid_at)
#

FactoryGirl.define do
  factory :agent_server do
    name { Faker::Hacker.ingverb }
    account
    distro "ubuntu"
    release "14.04"
    transient do
      with_bundle { false }
    end
    
    trait :centos do
      distro "centos"
      release "7"
    end


    trait :with_heartbeat do
      heartbeats { build_list :agent_heartbeat, 1 }
    end

    trait :with_bundle do
      transient do
        with_bundle { true }
      end
    end

    after(:create) do |s, f|
      if f.with_bundle
        rel = Platforms::PLATFORM_TO_RELEASE[s.distro][s.release]
        s.bundles << create(:bundle, account: s.account, platform: s.distro, release: rel)
      end
    end
  end

  factory :agent_heartbeat do
  end
end

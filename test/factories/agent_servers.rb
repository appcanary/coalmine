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
    trait :centos do
      distro "centos"
      release "7"
    end
  end
end

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
#  last_heartbeat   :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_agent_servers_on_account_id        (account_id)
#  index_agent_servers_on_agent_release_id  (agent_release_id)
#  index_agent_servers_on_uuid              (uuid)
#

FactoryGirl.define do
  factory :agent_server do
    account
    trait :centos do
      distro "centos"
      release "7"
    end
  end
end

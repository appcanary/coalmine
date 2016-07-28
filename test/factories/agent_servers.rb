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

FactoryGirl.define do
  factory :agent_server do
    account
    trait :centos do
      distro "centos"
      release "7"
    end
  end
end

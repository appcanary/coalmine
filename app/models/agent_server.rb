# == Schema Information
#
# Table name: agent_servers
#
#  id                :integer          not null, primary key
#  account_id        :integer
#  agent_release_id  :integer
#  uuid              :uuid
#  hostname          :string
#  uname             :string
#  name              :string
#  ip                :string
#  distro            :string
#  release           :string
#  last_heartbeat_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_agent_servers_on_account_id        (account_id)
#  index_agent_servers_on_agent_release_id  (agent_release_id)
#  index_agent_servers_on_uuid              (uuid)
#

class AgentServer < ActiveRecord::Base
  belongs_to :account
  validates :account, :presence => true

  belongs_to :agent_release
  has_many :bundles
  has_many :heartbeats, :class_name => AgentHeartbeat
  has_many :received_files, :class_name => AgentReceivedFile

  scope :belonging_to, -> (user) {
    where(:account_id => user.account_id)
  }

  def gone_silent?
    last_heartbeat_at < 2.hours.ago
  end

  def vulnerable?
    bundles.any?(&:vulnerable?)
  end

  def system_bundle
    self.bundles.where(:platform => Platforms::Ubuntu).first
  end
end

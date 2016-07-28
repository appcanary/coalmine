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

class AgentServer < ActiveRecord::Base
  belongs_to :account
  belongs_to :agent_release
  has_many :bundles
  has_many :heartbeats, :class_name => AgentHeartbeat
  has_many :received_files, :class_name => AgentReceivedFile

  def system_bundle
    self.bundles.where(:platform => Platforms::Ubuntu).first
  end
end

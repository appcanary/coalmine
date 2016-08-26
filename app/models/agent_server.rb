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
  default_scope { includes(:last_heartbeat) }
  belongs_to :account
  validates :account, :presence => true

  belongs_to :agent_release
  has_many :bundles
  has_many :heartbeats, :class_name => AgentHeartbeat
  has_many :received_files, :class_name => AgentReceivedFile

  has_one :last_heartbeat, -> { order(created_at: :desc) }, :class_name => AgentHeartbeat, :foreign_key => :agent_server_id

  scope :belonging_to, -> (user) {
    where(:account_id => user.account_id)
  }

  def last_heartbeat_at
    last_heartbeat.try(:created_at)
  end

  def register_heartbeat!(params)
    self.transaction do
      self.heartbeats.create!(:files => params[:files])

      agent_version = params[:"agent-version"]
      self.agent_release = AgentRelease.where(:version => agent_version).first_or_create!
      self.save!
    end
  end

  def display_name
    name.blank? ? hostname : name
  end

  def gone_silent?
    if last_heartbeat_at
      last_heartbeat_at < 2.hours.ago
    else
      true
    end
  end

  def vulnerable?
    bundles.any?(&:vulnerable?)
  end

  def system_bundle
    self.bundles.where(:platform => Platforms::Ubuntu).first
  end
end

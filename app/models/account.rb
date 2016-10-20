# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#  index_accounts_on_token  (token)
#

class Account < ActiveRecord::Base
  has_secure_token :token

  has_many :users

  has_many :agent_servers
  has_many :active_servers, -> { active }, :class_name => AgentServer
  has_many :bundles
  has_many :monitors, -> { where(:from_api => true) }, :class_name => Bundle

  has_many :log_bundle_vulnerabilities, :through => :bundles
  has_many :log_bundle_patches, :through => :bundles
  has_many :log_api_calls
  has_many :check_api_calls, -> { where(:action => "check/create") }, :class_name => LogApiCall

  has_many :email_messages
  has_many :email_patcheds
  has_many :email_vulnerables
  has_many :patched_notifications, :through => :email_patcheds, :source => :notifications
  has_many :vulnerable_notifications, :through => :email_vulnerables, :source => :notifications

  validates :email, uniqueness: true, presence: true, format: { with: /.+@.+\..+/i, message: "is not a valid address." }

  # def active_servers
  #   agent_servers.active
  # end

  def api_bundles
    bundles.where(:from_api => true)
  end

  # TODO: figure out how to reuse the active agent server
  # scope rather than this
  def active_server_bundles
    bundles.joins("inner join agent_servers on agent_servers.id = bundles.agent_server_id 
                   inner join agent_heartbeats on agent_heartbeats.agent_server_id = agent_servers.id").where("agent_heartbeats.created_at > ?", 2.hours.ago).distinct("agent_servers.id")
  end

  def server_bundles
    bundles.where("agent_server_id is not null")
  end

  def analytics_id
    self.datomic_id || self.id
  end

  def segment_stats
    {
      email: self.email,
      "server-count": self.agent_servers.count,
      "active-server-count": self.active_servers.count,
      "server-app-count": self.server_bundles.count,
      "active-server-app-count": self.active_server_bundles.count,
      "monitored-app-count": self.api_bundles.count,
      "api-calls-count": self.check_api_calls.count
    }
  end

end

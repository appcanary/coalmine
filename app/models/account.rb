# == Schema Information
#
# Table name: accounts
#
#  id                :integer          not null, primary key
#  email             :string           not null
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  datomic_id        :integer
#  notify_everything :boolean          default("false"), not null
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
  has_many :server_bundles, -> { via_agent }, :class_name => Bundle
  has_many :active_server_bundles, -> { joins(:agent_server).merge(AgentServer.active) }, :class_name => Bundle

  has_many :api_bundles, -> { via_api }, :class_name => Bundle
  has_many :monitors, -> { via_api }, :class_name => Bundle

  has_many :log_bundle_vulnerabilities, :through => :bundles
  has_many :log_bundle_patches, :through => :bundles
  has_many :log_api_calls
  has_many :check_api_calls, -> { where(:action => "check/create") }, :class_name => LogApiCall

  has_many :log_resolutions

  has_many :email_messages
  has_many :email_patcheds
  has_many :email_vulnerables
  has_many :patched_notifications, :through => :email_patcheds, :source => :notifications
  has_many :vulnerable_notifications, :through => :email_vulnerables, :source => :notifications
  has_many :tags

  validates :email, uniqueness: true, presence: true, format: { with: /.+@.+\..+/i, message: "is not a valid address." }

  scope :with_unnotified_vuln_logs, -> {
    where(:id => LogBundleVulnerability.unnotified_logs.
          select("distinct(bundles.account_id)"))
  }

  scope :with_unnotified_patch_logs, -> {
    where(:id => LogBundlePatch.unnotified_logs.
          select("distinct(bundles.account_id)"))
  }

   
  def self.have_tried_count
    self.count_by_sql("SELECT count(distinct(accounts.id)) FROM accounts WHERE EXISTS
                      (SELECT 1 FROM agent_servers WHERE agent_servers.account_id = accounts.id limit 1) OR EXISTS
                      (SELECT 1 FROM bundles WHERE bundles.account_id = accounts.id limit 1) OR EXISTS
                      (SELECT 1 FROM agent_server_archives WHERE agent_server_archives.account_id = accounts.id limit 1) OR EXISTS
                      (SELECT 1 FROM bundle_archives WHERE bundle_archives.account_id = accounts.id limit 1)")
  end


  def has_activity?
    active_servers.any? || 
      monitors.any?
  end


  def api_bundles
    bundles.where(:from_api => true)
  end

  def active_server_bundles
    bundles.joins(:agent_server).merge(AgentServer.active)
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

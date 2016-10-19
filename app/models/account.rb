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
  has_many :bundles

  has_many :log_bundle_vulnerabilities, :through => :bundles
  has_many :log_bundle_patches, :through => :bundles
  has_many :log_api_calls

  has_many :email_messages
  has_many :email_patcheds
  has_many :email_vulnerables
  has_many :patched_notifications, :through => :email_patcheds, :source => :notifications
  has_many :vulnerable_notifications, :through => :email_vulnerables, :source => :notifications

  validates :email, uniqueness: true, presence: true, format: { with: /.+@.+\..+/i, message: "is not a valid address." }

  def active_servers
    agent_servers.joins(:heartbeats).where('"agent_heartbeats".created_at > ?', 2.hours.ago)
  end

  def api_bundles
    bundles.where(:from_api => true)
  end

  def server_bundles
    bundles.where(:from_api => false)
  end

  def check_api_calls
    log_api_calls.where(:action => "check/create")
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
      "monitored-app-count": self.api_bundles.count,
      "api-calls-count": self.check_api_calls.count
    }
  end

end

class WebhookVulnerable < WebhookMessage
  belongs_to :account
  belongs_to :webhook
  has_many :notifications, -> { where("log_bundle_vulnerability_id is not null") }, :foreign_key => "webhook_message_id", :dependent => :destroy

  has_many :logs, :source => :log_bundle_vulnerability, :through => :notifications
end

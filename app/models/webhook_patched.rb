class WebhookPatched < WebhookMessage
  belongs_to :account
  belongs_to :webhook
  has_many :notifications, -> { where("log_bundle_patch_id is not null") }, :foreign_key => "webhook_message_id", :dependent => :destroy

  has_many :logs, :source => :log_bundle_patch, :through => :notifications
end

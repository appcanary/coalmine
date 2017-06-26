class AddWebhookToNotification < ActiveRecord::Migration
  def change
    add_reference :notifications, :webhook_message, index: true, foreign_key: true
  end
end

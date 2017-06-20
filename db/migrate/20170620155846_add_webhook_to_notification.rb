class AddWebhookToNotification < ActiveRecord::Migration
  def change
    add_reference :notifications, :webhook, index: true, foreign_key: true
  end
end

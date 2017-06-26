class MakeNotificationEmailMessageIdNotNull < ActiveRecord::Migration
  def change
    change_column :notifications, :email_message_id, :int, :null => true
  end
end

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :email_message, index: true, foreign_key: true, null: false
      t.references :log_bundle_vulnerability, index: true, foreign_key: true
      t.references :log_bundle_patch, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

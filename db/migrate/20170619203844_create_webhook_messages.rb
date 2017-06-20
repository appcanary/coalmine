class CreateWebhookMessages < ActiveRecord::Migration
  def change
    create_table :webhook_messages do |t|
      t.references :account, index: true, foreign_key: true
      t.references :webhook, index: true, foreign_key: true
      t.string :url
      t.string :type
      t.datetime :sent_at

      t.timestamps null: false
    end
  end
end

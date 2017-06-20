class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.references :account, index: true, foreign_key: true
      t.text :url

      t.timestamps null: false
    end
  end
end

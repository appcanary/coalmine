class CreateEmailMessages < ActiveRecord::Migration
  def change
    create_table :email_messages do |t|
      t.references :account, index: true, foreign_key: true, null: false
      t.string :recipients, array: true, default: [], null: false
      t.string :type, null: false
      t.datetime :sent_at, index: true
      t.timestamps null: false
    end
  end
end

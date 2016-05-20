class CreatePallets < ActiveRecord::Migration
  def change
    create_table :pallets do |t|
      t.reference :account_id
      t.string :name
      t.string :path
      t.string :kind
      t.string :release
      t.long :last_crc
      t.boolean :from_api

      t.timestamps null: false
    end
  end
end

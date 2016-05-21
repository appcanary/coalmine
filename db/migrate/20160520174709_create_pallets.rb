class CreatePallets < ActiveRecord::Migration
  def change
    create_table :pallets do |t|
      t.references :account
      t.string :name
      t.string :path
      t.string :kind
      t.string :release
      t.integer :last_crc, :limit => 8
      t.boolean :from_api

      t.timestamps null: false
    end
  end
end

class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.references :account, index: true, foreign_key: true, null: false
      t.string :name
      t.string :path
      t.string :platform, null: false
      t.string :release
      t.integer :last_crc, :limit => 8
      t.boolean :from_api
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end

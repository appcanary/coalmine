class CreatePackageSets < ActiveRecord::Migration
  def change
    create_table :package_sets do |t|
      t.references :account, index: true, foreign_key: true
      t.string :name
      t.string :path
      t.string :kind
      t.string :release
      t.integer :last_crc, :limit => 8
      t.boolean :from_api
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end

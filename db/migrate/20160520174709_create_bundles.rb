class CreateBundles < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :bundles do |t|
      t.references :account, index: true, foreign_key: true, null: false
      t.references :agent_server, index: true
      t.string :name
      t.string :path
      t.string :platform, null: false
      t.string :release
      t.integer :last_crc, :limit => 8
      t.boolean :being_watched
      t.boolean :from_api
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :bundles, [:account_id, :agent_server_id]
    add_index :bundles, [:account_id, :agent_server_id, :path]
  end
end

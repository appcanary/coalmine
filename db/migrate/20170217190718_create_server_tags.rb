class CreateServerTags < ActiveRecord::Migration
  def change
    create_table :server_tags do |t|
      t.text :tag
      t.belongs_to :agent_server, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :server_tags, [:tag, :agent_server_id], unique: true
  end
end

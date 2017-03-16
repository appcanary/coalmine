class CreateServerTags < ActiveRecord::Migration
  def change
    create_table :server_tags do |t|
      t.belongs_to :agent_server, index: true, foreign_key: true
      t.belongs_to :tag, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :server_tags, [:agent_server_id, :tag_id], unique: true
  end
end

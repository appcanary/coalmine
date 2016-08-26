class CreateAgentHeartbeats < ActiveRecord::Migration
  def change
    create_table :agent_heartbeats do |t|
      t.references :agent_server, index: true, null: false
      t.text :files

      t.timestamps null: false
    end

    add_index :agent_heartbeats, :created_at
  end
end

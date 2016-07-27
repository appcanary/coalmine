class CreateAgentHeartbeats < ActiveRecord::Migration
  def change
    create_table :agent_heartbeats do |t|
      t.references :agent_server, index: true, foreign_key: true
      t.text :files

      t.timestamps null: false
    end
  end
end

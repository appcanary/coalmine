class ChangeIndexOnAgentHeartBeats < ActiveRecord::Migration
  def up
    remove_index :agent_heartbeats, [:id, :created_at]
    add_index :agent_heartbeats, [:agent_server_id, :created_at], order: {created_at: :desc, agent_server_id: :asc}
  end

  def down
    remove_index :agent_heartbeats, [:agent_server_id, :created_at]
    add_index :agent_heartbeats, [:id, :created_at], order: {created_at: :desc, id: :asc}
  end
end

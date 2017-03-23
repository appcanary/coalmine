class AddIndexToAgentHeartbeatsCreatedAndId < ActiveRecord::Migration
  def change
    remove_index :agent_heartbeats, column: :created_at
    add_index :agent_heartbeats, [:id, :created_at], order: {created_at: :desc, id: :asc}

    # add_index :agent_heartbeats, :created_at, order: {created_at: :desc}
  end
end

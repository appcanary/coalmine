class RemoveForeignKeyFromAgentAcceptedFiles < ActiveRecord::Migration
  def change
    remove_foreign_key :agent_accepted_files, column: :account_id
    remove_foreign_key :agent_accepted_files, column: :agent_server_id

    remove_foreign_key :agent_received_files, column: :account_id
    remove_foreign_key :agent_received_files, column: :agent_server_id
  end
end

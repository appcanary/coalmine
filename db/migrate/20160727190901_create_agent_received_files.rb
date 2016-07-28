class CreateAgentReceivedFiles < ActiveRecord::Migration
  def change
    create_table :agent_received_files do |t|
      t.references :account, index: true, foreign_key: true, null: false
      t.references :agent_server, index: true, foreign_key: true, null: false
      t.text :request

      t.timestamps null: false
    end
  end
end

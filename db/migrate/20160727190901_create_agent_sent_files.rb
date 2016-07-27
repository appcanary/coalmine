class CreateAgentSentFiles < ActiveRecord::Migration
  def change
    create_table :agent_sent_files do |t|
      t.references :account, index: true, foreign_key: true
      t.references :agent_server, index: true, foreign_key: true
      t.text :request

      t.timestamps null: false
    end
  end
end

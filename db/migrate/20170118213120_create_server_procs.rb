class CreateServerProcs < ActiveRecord::Migration
  def change
    create_table :server_procs do |t|
      t.references :agent_server, index: true, foreign_key: true, null: false

      t.integer :pid, null: false
      t.string :command_line
      t.datetime :started

      t.timestamps null: false
    end
  end
end

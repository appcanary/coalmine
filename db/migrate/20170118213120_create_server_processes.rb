class CreateServerProcesses < ActiveRecord::Migration
  def change
    create_table :server_processes do |t|
      t.references :agent_server, index: true, foreign_key: true, null: false

      t.integer :pid, null: false
      t.string :name
      t.datetime :started

      t.timestamps null: false
    end
  end
end

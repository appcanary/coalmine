class CreateAgentServers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :agent_servers do |t|
      t.references :account, index: true, foreign_key: true
      t.references :agent_release, index: true, foreign_key: true
      t.uuid :uuid, null: false, default: 'uuid_generate_v4()', index: true
      t.string :hostname
      t.string :uname
      t.string :name
      t.string :ip
      t.string :distro
      t.string :release
      t.datetime :last_heartbeat_at

      t.timestamps null: false
    end
  end
end

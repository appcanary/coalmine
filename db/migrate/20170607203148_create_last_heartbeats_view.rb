class CreateLastHeartbeatsView < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE VIEW last_heartbeats as
SELECT agent_servers.id as agent_server_id,
       agent_heartbeats.id as agent_heartbeat_id,
       agent_heartbeats.created_at as last_heartbeat_at
FROM agent_servers LEFT OUTER JOIN agent_heartbeats ON
     agent_heartbeats.agent_server_id = agent_servers.id AND
     agent_heartbeats.id = (SELECT  agent_heartbeats.id
                            FROM agent_heartbeats
                            WHERE agent_heartbeats.agent_server_id = agent_servers.id
                            ORDER BY agent_heartbeats.created_at DESC LIMIT 1)
SQL
  end

  def down
    execute "DROP VIEW last_heartbeats"
  end
end

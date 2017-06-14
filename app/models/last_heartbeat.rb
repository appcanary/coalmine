class LastHeartbeat < ActiveRecord::Base
  belongs_to :agent_server
  belongs_to :agent_heartbeat
end

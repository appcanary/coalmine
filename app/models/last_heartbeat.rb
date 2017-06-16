# == Schema Information
#
# Table name: last_heartbeats
#
#  agent_server_id    :integer
#  agent_heartbeat_id :integer
#  last_heartbeat_at  :datetime
#

class LastHeartbeat < ActiveRecord::Base
  belongs_to :agent_server
  belongs_to :agent_heartbeat
end

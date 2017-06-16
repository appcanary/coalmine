# == Schema Information
#
# Table name: agent_heartbeats
#
#  id              :integer          not null, primary key
#  agent_server_id :integer          not null
#  files           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_agent_heartbeats_on_agent_server_id                 (agent_server_id)
#  index_agent_heartbeats_on_agent_server_id_and_created_at  (agent_server_id,created_at)
#

class AgentHeartbeat < ActiveRecord::Base
  belongs_to :agent_server
end

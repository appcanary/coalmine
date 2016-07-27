# == Schema Information
#
# Table name: agent_heartbeats
#
#  id              :integer          not null, primary key
#  agent_server_id :integer
#  files           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AgentHeartbeat < ActiveRecord::Base
  belongs_to :agent_server
end

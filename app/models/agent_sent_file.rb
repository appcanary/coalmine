class AgentSentFile < ActiveRecord::Base
  belongs_to :account
  belongs_to :agent_server
end

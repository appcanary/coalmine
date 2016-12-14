class AgentAcceptedFile < ActiveRecord::Base
  belongs_to :agent_server
  belongs_to :account


end

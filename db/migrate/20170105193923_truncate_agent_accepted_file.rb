class TruncateAgentAcceptedFile < ActiveRecord::Migration
  def change
    AgentAcceptedFile.delete_all
  end
end

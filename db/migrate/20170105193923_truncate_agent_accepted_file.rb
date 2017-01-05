class TruncateAgentAcceptedFile < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("truncate agent_accepted_files;")
  end
end

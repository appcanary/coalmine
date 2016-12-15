# == Schema Information
#
# Table name: agent_accepted_files
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  agent_server_id :integer          not null
#  request         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_agent_accepted_files_on_account_id       (account_id)
#  index_agent_accepted_files_on_agent_server_id  (agent_server_id)
#

class AgentAcceptedFile < ActiveRecord::Base
  belongs_to :agent_server
  belongs_to :account


end

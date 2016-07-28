# == Schema Information
#
# Table name: agent_received_files
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  agent_server_id :integer          not null
#  request         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AgentReceivedFile < ActiveRecord::Base
  belongs_to :account
  belongs_to :agent_server
end

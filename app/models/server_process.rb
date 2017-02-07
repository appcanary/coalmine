# == Schema Information
#
# Table name: server_processes
#
#  id              :integer          not null, primary key
#  agent_server_id :integer          not null
#  pid             :integer          not null
#  name            :string
#  started         :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_server_processes_on_agent_server_id  (agent_server_id)
#

class ServerProcess < ActiveRecord::Base
  belongs_to :agent_server
  has_many :server_process_libraries, :dependent => :destroy
  has_many :process_libraries, :through => :server_process_libraries
end

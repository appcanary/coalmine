class ServerProcess < ActiveRecord::Base
  belongs_to :agent_server
  has_many :server_process_libraries, :dependent => :destroy
  has_many :process_libraries, :through => :server_process_libraries
end

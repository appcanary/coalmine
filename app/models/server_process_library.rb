class ServerProcessLibrary < ActiveRecord::Base
  belongs_to :server_process
  belongs_to :process_library
end

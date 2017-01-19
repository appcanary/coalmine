class ServerProcLib < ActiveRecord::Base
  belongs_to :server_proc
  belongs_to :proc_lib
end

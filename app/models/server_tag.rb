class ServerTag < ActiveRecord::Base
  belongs_to :agent_server
  belongs_to :tag
end

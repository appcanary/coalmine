class Tag < ActiveRecord::Base
  has_many :server_tags
  has_many :agent_servers, :through => :server_tags
end

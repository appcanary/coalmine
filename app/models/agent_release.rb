# == Schema Information
#
# Table name: agent_releases
#
#  id         :integer          not null, primary key
#  version    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AgentRelease < ActiveRecord::Base
  has_many :agent_servers
end

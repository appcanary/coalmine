# == Schema Information
#
# Table name: server_tags
#
#  id              :integer          not null, primary key
#  agent_server_id :integer
#  tag_id          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_server_tags_on_agent_server_id             (agent_server_id)
#  index_server_tags_on_agent_server_id_and_tag_id  (agent_server_id,tag_id) UNIQUE
#  index_server_tags_on_tag_id                      (tag_id)
#

class ServerTag < ActiveRecord::Base
  belongs_to :agent_server
  belongs_to :tag
end

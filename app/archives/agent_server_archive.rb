# == Schema Information
#
# Table name: agent_server_archives
#
#  id               :integer          not null, primary key
#  agent_server_id  :integer          not null
#  account_id       :integer
#  agent_release_id :integer
#  uuid             :uuid
#  hostname         :string
#  uname            :string
#  name             :string
#  ip               :string
#  distro           :string
#  release          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         not null
#
# Indexes
#
#  idx_agent_server_id_ar                           (agent_server_id)
#  index_agent_server_archives_on_account_id        (account_id)
#  index_agent_server_archives_on_agent_release_id  (agent_release_id)
#  index_agent_server_archives_on_expired_at        (expired_at)
#  index_agent_server_archives_on_uuid              (uuid)
#  index_agent_server_archives_on_valid_at          (valid_at)
#

class AgentServerArchive < ActiveRecord::Base
  extend ArchiveTableBehaviour
  belongs_to :account

  scope :deleted, -> {
    select_as_archived.
    # look only at the most recently expired rows
    joins("inner join (select agent_server_id, max(expired_at) expired_at from agent_server_archives group by agent_server_id) max_asa on agent_server_archives.agent_server_id = max_asa.agent_server_id and agent_server_archives.expired_at = max_asa.expired_at").
    # look only at rows that do not currently exist in AgentServer table
    joins("left join agent_servers on agent_servers.id = agent_server_archives.agent_server_id").
    where("agent_servers.id is null").
    order("id, agent_server_archives.expired_at DESC")

  }

     
  # note for later:
  # select agent_server_archives.* from agent_server_archives inner join (select agent_server_id, max(id) id from agent_server_archives WHERE (valid_at >= '2017-01-12 00:00:00.000000' and valid_at <= '2017-01-12 23:59:59.999999') group by agent_server_id) specific_as 
  # ON specific_as.id = agent_server_archives.id 
  # left join agent_servers on agent_server_archives.agent_server_id = agent_servers.id
  # where agent_servers.id is null and agent_server_archives.account_id = 22
  # order by agent_server_archives.agent_server_id

  #TODO: this should be in the presenter
  def display_name
    name.blank? ? hostname : name
  end
end

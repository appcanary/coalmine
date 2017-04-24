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

  #TODO: this should be in the presenter
  def display_name
    name.blank? ? hostname : name
  end
end

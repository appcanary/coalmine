# == Schema Information
#
# Table name: bundle_archives
#
#  id              :integer          not null, primary key
#  bundle_id       :integer          not null
#  account_id      :integer          not null
#  agent_server_id :integer
#  name            :string
#  path            :string
#  platform        :string           not null
#  release         :string
#  last_crc        :integer
#  being_watched   :boolean
#  from_api        :boolean
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  valid_at        :datetime         not null
#  expired_at      :datetime         not null
#
# Indexes
#
#  idx_bundle_id_ar                          (bundle_id)
#  index_bundle_archives_on_account_id       (account_id)
#  index_bundle_archives_on_agent_server_id  (agent_server_id)
#  index_bundle_archives_on_expired_at       (expired_at)
#  index_bundle_archives_on_valid_at         (valid_at)
#

class BundleArchive < ActiveRecord::Base
  belongs_to :account
  
  scope :via_api, -> { where("bundle_archives.agent_server_id is null") }

  # TODO: this should be in the presenter
  def display_name
    if agent_server_id.present? and self.system_bundle?
      "System Packages"
    else
      name.blank? ? path : name
    end
  end
end

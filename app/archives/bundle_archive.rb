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

  ARCHIVED_COL = self.table_name.gsub("archives", "id")
  ARCHIVED_SELECT = self.columns.reduce([]) { |list, col|
    if col.name == "id"
      list
    elsif col.name == ARCHIVED_COL
      list << "#{self.table_name}.#{col.name} as id"
    else
      list << "#{self.table_name}.#{col.name}"
    end
  }.join(", ")


  scope :select_as_archived, -> { 
    select(ARCHIVED_SELECT)
  }

  scope :via_api, -> { where("bundle_archives.agent_server_id is null") }

  scope :deleted, -> {
    select_as_archived.
      # look only at the most recently expired rows
      joins("inner join (select bundle_id, max(expired_at) expired_at from bundle_archives group by bundle_id) max_ba on bundle_archives.bundle_id = max_ba.bundle_id and bundle_archives.expired_at = max_ba.expired_at").
      # look only at rows that do not currently exist in AgentServer table
      joins("left join bundles on bundles.id = bundle_archives.bundle_id").
      where("bundles.id is null").
      order("id, bundle_archives.expired_at DESC")

  }



  # TODO: this should be in the presenter
  def display_name
    if agent_server_id.present? and self.system_bundle?
      "System Packages"
    else
      name.blank? ? path : name
    end
  end
end

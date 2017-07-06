# == Schema Information
#
# Table name: daily_summaries
#
#  id                                :integer          not null, primary key
#  account_id                        :integer
#  date                              :date
#  all_vuln_ct                       :integer
#  all_server_ids                    :integer          is an Array
#  new_server_ids                    :integer          is an Array
#  deleted_server_ids                :integer          is an Array
#  all_monitor_ids                   :integer          is an Array
#  new_monitor_ids                   :integer          is an Array
#  deleted_monitor_ids               :integer          is an Array
#  fresh_vulns_vuln_pkg_ids          :json
#  fresh_vulns_server_ids            :integer          is an Array
#  fresh_vulns_monitor_ids           :integer          is an Array
#  fresh_vulns_package_ids           :integer          is an Array
#  fresh_vulns_supplementary_count   :integer
#  new_vulns_vuln_pkg_ids            :json             is an Array
#  new_vulns_server_ids              :integer          is an Array
#  new_vulns_monitor_ids             :integer          is an Array
#  new_vulns_package_ids             :integer          is an Array
#  new_vulns_supplementary_count     :integer
#  patched_vulns_vuln_pkg_ids        :json
#  patched_vulns_server_ids          :integer          is an Array
#  patched_vulns_monitor_ids         :integer          is an Array
#  patched_vulns_package_ids         :integer          is an Array
#  patched_vulns_supplementary_count :integer
#  cantfix_vulns_vuln_pkg_ids        :json
#  cantfix_vulns_server_ids          :integer          is an Array
#  cantfix_vulns_monitor_ids         :integer          is an Array
#  cantfix_vulns_package_ids         :integer          is an Array
#  cantfix_vulns_supplementary_count :integer
#  changes_server_count              :integer
#  changes_monitor_count             :integer
#  changes_added_count               :integer
#  changes_removed_count             :integer
#  changes_upgraded_count            :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_daily_summaries_on_account_id  (account_id)
#  index_daily_summaries_on_date        (date)
#

class DailySummary < ActiveRecord::Base
  belongs_to :account

  # TODO: these queries need to include the archives also, we should find a way to speed them up or abstract this.

  def all_servers
    @all_servers ||= AgentServer.from(AgentServer.union_str(AgentServer.where(id: all_server_ids), AgentServer.deleted.where(agent_server_id: all_server_ids)))
  end

  def new_servers
    @new_servers ||= AgentServer.from(AgentServer.union_str(AgentServer.where(id: new_server_ids), AgentServer.deleted.where(agent_server_id: new_server_ids)))
  end

  def deleted_servers
    @deleted_servers ||= AgentServer.from(AgentServer.union_str(AgentServer.where(id: deleted_server_ids), AgentServer.deleted.where(agent_server_id: deleted_server_ids)))
  end

  def all_monitors
    @all_monitors ||= Bundle.from(Bundle.union_str(Bundle.where(id: all_monitor_ids), Bundle.deleted.where(bundle_id: all_monitor_ids)))
  end

  def new_monitors
    @new_monitors ||= Bundle.from(Bundle.union_str(Bundle.where(id: new_monitor_ids), Bundle.deleted.where(bundle_id: new_monitor_ids)))
  end

  def deleted_monitors
    @deleted_monitors ||= Bundle.from(Bundle.union_str(Bundle.where(id: deleted_monitor_ids), Bundle.deleted.where(bundle_id: deleted_monitor_ids)))
  end
end

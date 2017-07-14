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

  def self.sort_group_log_vulns(query)
    query.group_by(&:vulnerability).
      reduce({}) { |hsh, (vuln, logs)|
      hsh[vuln] = logs.map(&:package_id).uniq
      hsh

    }.sort_by { |vuln, pkgs|
      [-vuln.criticality_ordinal, -pkgs.size]
    }.map { |vuln, pkgs|
      [vuln.id, pkgs]
    }
  end


  def self.tabulate_subquery(q)
    # Get the results we need to pull out of a subquery like new_vulns, fresh_vulns, etca
    {
      vuln_pkg_ids: sort_group_log_vulns(q),
      server_ids: q.pluck(:agent_server_id).select(&:present?).uniq,
      monitor_ids: q.select{|lbv| lbv.agent_server_id.nil?}.map(&:bundle_id).uniq,
      package_ids: q.pluck(:package_id).uniq,
      supplementary_count: q.select(&:supplementary).map(&:vulnerability_id).uniq.size
    }
  end

  def self.from_query(dsq)
    ds = self.new
    ds.account_id = dsq.account.id
    ds.date =  dsq.date

    ds.all_vuln_ct = dsq.all_vuln_ct

    ds.all_server_ids = dsq.all_servers.pluck(:id)
    ds.new_server_ids = dsq.new_servers.pluck(:id)
    ds.deleted_server_ids = dsq.deleted_servers.pluck(:id)

    ds.active_server_count = dsq.all_servers.active_as_of(ds.date).count

    ds.all_monitor_ids = dsq.all_monitors.pluck(:id)
    ds.new_monitor_ids = dsq.new_monitors.pluck(:id)
    ds.deleted_monitor_ids = dsq.deleted_monitors.pluck(:id)

    ds.changes_server_count = dsq.changes[:server_ct]
    ds.changes_monitor_count = dsq.changes[:monitor_ct]
    ds.changes_added_count = dsq.changes[:added_ct]
    ds.changes_removed_count = dsq.changes[:removed_ct]
    ds.changes_upgraded_count = dsq.changes[:upgraded_ct]

    fresh_vulns = tabulate_subquery(dsq.fresh_vulns)
    ds.fresh_vulns_vuln_pkg_ids = fresh_vulns[:vuln_pkg_ids]
    ds.fresh_vulns_server_ids = fresh_vulns[:server_ids]
    ds.fresh_vulns_monitor_ids = fresh_vulns[:monitor_ids]
    ds.fresh_vulns_package_ids = fresh_vulns[:package_ids]
    ds.fresh_vulns_supplementary_count = fresh_vulns[:supplementary_count]

    new_vulns = tabulate_subquery(dsq.new_vulns)
    ds.new_vulns_vuln_pkg_ids = new_vulns[:vuln_pkg_ids]
    ds.new_vulns_server_ids = new_vulns[:server_ids]
    ds.new_vulns_monitor_ids = new_vulns[:monitor_ids]
    ds.new_vulns_package_ids = new_vulns[:package_ids]
    ds.new_vulns_supplementary_count = new_vulns[:supplementary_count]

    patched_vulns = tabulate_subquery(dsq.patched_vulns)
    ds.patched_vulns_vuln_pkg_ids = patched_vulns[:vuln_pkg_ids]
    ds.patched_vulns_server_ids = patched_vulns[:server_ids]
    ds.patched_vulns_monitor_ids = patched_vulns[:monitor_ids]
    ds.patched_vulns_package_ids = patched_vulns[:package_ids]
    ds.patched_vulns_supplementary_count = patched_vulns[:supplementary_count]

    cantfix_vulns = tabulate_subquery(dsq.cantfix_vulns)
    ds.cantfix_vulns_vuln_pkg_ids = cantfix_vulns[:vuln_pkg_ids]
    ds.cantfix_vulns_server_ids = cantfix_vulns[:server_ids]
    ds.cantfix_vulns_monitor_ids = cantfix_vulns[:monitor_ids]
    ds.cantfix_vulns_package_ids = cantfix_vulns[:package_ids]
    ds.cantfix_vulns_supplementary_count = cantfix_vulns[:supplementary_count]

    ds
  end
end

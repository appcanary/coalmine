# == Schema Information
#
# Table name: daily_summaries
#
#  id                        :integer          not null, primary key
#  account_id                :integer
#  date                      :date
#  fresh_vulns_vuln_ids      :integer          is an Array
#  fresh_vulns_server_ids    :integer          is an Array
#  fresh_vulns_monitor_ids   :integer          is an Array
#  fresh_vulns_package_ids   :integer          is an Array
#  new_vulns_vuln_ids        :integer          is an Array
#  new_vulns_server_ids      :integer          is an Array
#  new_vulns_monitor_ids     :integer          is an Array
#  new_vulns_package_ids     :integer          is an Array
#  patched_vulns_vuln_ids    :integer          is an Array
#  patched_vulns_server_ids  :integer          is an Array
#  patched_vulns_monitor_ids :integer          is an Array
#  patched_vulns_package_ids :integer          is an Array
#  cantfix_vulns_vuln_ids    :integer          is an Array
#  cantfix_vulns_server_ids  :integer          is an Array
#  cantfix_vulns_monitor_ids :integer          is an Array
#  cantfix_vulns_package_ids :integer          is an Array
#  changes_server_count      :integer
#  changes_monitor_count     :integer
#  changes_added_count       :integer
#  changes_removed_count     :integer
#  canges_upgraded_count     :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_daily_summaries_on_account_id                 (account_id)
#  index_daily_summaries_on_cantfix_vulns_monitor_ids  (cantfix_vulns_monitor_ids)
#  index_daily_summaries_on_cantfix_vulns_package_ids  (cantfix_vulns_package_ids)
#  index_daily_summaries_on_cantfix_vulns_server_ids   (cantfix_vulns_server_ids)
#  index_daily_summaries_on_cantfix_vulns_vuln_ids     (cantfix_vulns_vuln_ids)
#  index_daily_summaries_on_fresh_vulns_monitor_ids    (fresh_vulns_monitor_ids)
#  index_daily_summaries_on_fresh_vulns_package_ids    (fresh_vulns_package_ids)
#  index_daily_summaries_on_fresh_vulns_server_ids     (fresh_vulns_server_ids)
#  index_daily_summaries_on_fresh_vulns_vuln_ids       (fresh_vulns_vuln_ids)
#  index_daily_summaries_on_new_vulns_monitor_ids      (new_vulns_monitor_ids)
#  index_daily_summaries_on_new_vulns_package_ids      (new_vulns_package_ids)
#  index_daily_summaries_on_new_vulns_server_ids       (new_vulns_server_ids)
#  index_daily_summaries_on_new_vulns_vuln_ids         (new_vulns_vuln_ids)
#  index_daily_summaries_on_patched_vulns_monitor_ids  (patched_vulns_monitor_ids)
#  index_daily_summaries_on_patched_vulns_package_ids  (patched_vulns_package_ids)
#  index_daily_summaries_on_patched_vulns_server_ids   (patched_vulns_server_ids)
#  index_daily_summaries_on_patched_vulns_vuln_ids     (patched_vulns_vuln_ids)
#

FactoryGirl.define do
  factory :daily_summary do
    account nil
date "2017-07-05"
  end

end

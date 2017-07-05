class CreateDailySummaries < ActiveRecord::Migration
  def change
    create_table :daily_summaries do |t|
      t.references :account, index: true, foreign_key: true
      t.date :date

      t.integer :fresh_vulns_vuln_ids, index: true, array: true
      t.integer :fresh_vulns_server_ids, index: true, array: true
      t.integer :fresh_vulns_monitor_ids, index: true, array: true
      t.integer :fresh_vulns_package_ids, index: true, array: true

      t.integer :new_vulns_vuln_ids, index: true, array: true
      t.integer :new_vulns_server_ids, index: true, array: true
      t.integer :new_vulns_monitor_ids, index: true, array: true
      t.integer :new_vulns_package_ids, index: true, array: true

      t.integer :patched_vulns_vuln_ids, index: true, array: true
      t.integer :patched_vulns_server_ids, index: true, array: true
      t.integer :patched_vulns_monitor_ids, index: true, array: true
      t.integer :patched_vulns_package_ids, index: true, array: true

      t.integer :cantfix_vulns_vuln_ids, index: true, array: true
      t.integer :cantfix_vulns_server_ids, index: true, array: true
      t.integer :cantfix_vulns_monitor_ids, index: true, array: true
      t.integer :cantfix_vulns_package_ids, index: true, array: true



      t.integer :changes_server_count
      t.integer :changes_monitor_count
      t.integer :changes_added_count
      t.integer :changes_removed_count
      t.integer :canges_upgraded_count


      t.timestamps null: false
    end
  end
end

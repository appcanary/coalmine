class CreateDailySummaries < ActiveRecord::Migration
  def change
    create_table :daily_summaries do |t|
      t.references :account, index: true, foreign_key: true, null: false
      t.date :date, index: true, null: false

      t.integer :all_vuln_ct, null: false

      t.integer :all_server_ids, array: true, null: false
      t.integer :new_server_ids, array: true, null: false
      t.integer :deleted_server_ids, array: true, null: false
      t.integer :active_server_count, null: false

      t.integer :all_monitor_ids, array: true, null: false
      t.integer :new_monitor_ids, array: true, null: false
      t.integer :deleted_monitor_ids, array: true, null: false

      t.json :fresh_vulns_vuln_pkg_ids, null: false
      t.integer :fresh_vulns_server_ids, array: true, null: false
      t.integer :fresh_vulns_monitor_ids, array: true, null: false
      t.integer :fresh_vulns_package_ids, array: true, null: false
      t.integer :fresh_vulns_supplementary_count, null: false

      t.json :new_vulns_vuln_pkg_ids, null: false
      t.integer :new_vulns_server_ids, array: true, null: false
      t.integer :new_vulns_monitor_ids, array: true, null: false
      t.integer :new_vulns_package_ids, array: true, null: false
      t.integer :new_vulns_supplementary_count, null: false

      t.json :patched_vulns_vuln_pkg_ids, null: false
      t.integer :patched_vulns_server_ids, array: true, null: false
      t.integer :patched_vulns_monitor_ids, array: true, null: false
      t.integer :patched_vulns_package_ids, array: true, null: false
      t.integer :patched_vulns_supplementary_count, null: false

      t.json :cantfix_vulns_vuln_pkg_ids, null: false
      t.integer :cantfix_vulns_server_ids, array: true, null: false
      t.integer :cantfix_vulns_monitor_ids, array: true, null: false
      t.integer :cantfix_vulns_package_ids, array: true, null: false
      t.integer :cantfix_vulns_supplementary_count, null: false

      t.integer :changes_server_count, null: false
      t.integer :changes_monitor_count, null: false
      t.integer :changes_added_count, null: false
      t.integer :changes_removed_count, null: false
      t.integer :changes_upgraded_count, null: false

      t.timestamps null: false
    end
    add_index :daily_summaries, [:account_id, :date], :unique => true
  end
end

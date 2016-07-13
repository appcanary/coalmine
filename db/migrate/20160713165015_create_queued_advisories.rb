class CreateQueuedAdvisories < ActiveRecord::Migration
  def change
    create_table :queued_advisories do |t|

      t.string :advisory_id, null: false, index: true
      t.string :package_names, array:true, :default => [], null: false
      t.string :package_platform, null: false
      t.string :title
      t.datetime :reported_at
      t.text :description
      t.string :criticality
      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false
      t.string :cve_ids, array: true, :default => [], null: false
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :importer

      t.datetime :created_at, null: false
    end
  end
end

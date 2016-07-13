class CreateAdvisoryQueues < ActiveRecord::Migration
  def change
    create_table :advisory_queues do |t|

      t.string :advisory_id, null: false, index: true
      t.string :package_names, array:true, :default => [], null: false
      t.string :package_platform, null: false
      t.string :title
      t.datetime :reported_at
      t.text :description
      t.string :criticality
      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false

      # todo delete this
      t.string :cve_id

      t.string :cve_ids, array: true, :default => [], null: false
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :source

      t.datetime :created_at, null: false
    end
  end
end

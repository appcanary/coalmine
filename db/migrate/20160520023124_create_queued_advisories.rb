class CreateQueuedAdvisories < ActiveRecord::Migration
  def change
    create_table :queued_advisories do |t|
      t.string :identifier, null: false, index: true

      t.string :package_platform, null: false
      t.string :package_names, array:true, :default => [], null: false

      t.jsonb :patched, :default => [], null: false
      t.jsonb :affected, :default => [], null: false
      t.jsonb :unaffected, :default => [], null: false

      t.string :title
      t.text :description
      t.string :criticality

      t.string :cve_ids, array: true, :default => [], null: false
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :alas_id
      t.string :debianbug
      t.string :source

      t.datetime :reported_at
      t.datetime :created_at, null: false
    end
  end
end

class CreateAdvisories < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :advisories do |t|
      t.references :queued_advisory, null: false, index: true
      t.string :identifier, null: false, index: true

      t.string :package_platform, null: false
      t.string :package_names, array:true, :default => [], null: false

      t.string :affected_arches, array: true, :default => [], null: false
      t.string :affected_releases, array: true, :default => [], null: false

      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false

      t.string :title
      t.text :description
      t.string :criticality

      t.string :cve_ids, array: true, :default => [], null: false
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :source

      t.datetime :reported_at
      t.timestamps null: false
    end
  end
end

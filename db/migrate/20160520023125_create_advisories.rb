class CreateAdvisories < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :advisories do |t|
      t.string :identifier, null: false, index: true
      t.string :package_platform, null: false
 
      t.string :package_names, array:true, :default => [], null: false

      t.jsonb :patched, :default => [], null: false
      t.jsonb :affected, :default => [], null: false
      t.jsonb :unaffected, :default => [], null: false


      # t.string :affected_arches, array: true, :default => [], null: false
      # t.string :affected_releases, array: true, :default => [], null: false

      # t.text :patched_versions, array: true, :default => [], null: false
      # t.text :unaffected_versions, array: true, :default => [], null: false

      t.string :title
      t.text :description
      t.string :criticality
      t.jsonb :related, :default => [], null: false

      t.string :cve_ids, array: true, :default => [], null: false
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
 
      t.text :source_text
      t.string :source, null: false, index: true
      t.boolean :processed, default: false, null: false, index: true

      t.datetime :reported_at
      t.timestamps null: false
    end
  end
end

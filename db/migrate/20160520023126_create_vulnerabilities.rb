class CreateVulnerabilities < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerabilities do |t|
      t.string :package_name, null: false
      t.string :package_platform, null: false
      t.string :title
      t.datetime :reported_at
      t.text :description
      t.string :criticality
      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false
      t.string :cve_id
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :source

      t.timestamps null: false
    end
  end
end

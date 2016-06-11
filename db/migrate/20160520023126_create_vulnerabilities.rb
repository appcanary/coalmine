class CreateVulnerabilities < ActiveRecord::Migration
  def change
    create_table :vulnerabilities do |t|
      t.string :package_name
      t.string :package_platform
      t.string :title
      t.datetime :reported_at
      t.text :description
      t.string :criticality
      t.text :patched_versions, array: true, :default => []
      t.text :unaffected_versions, array: true, :default => []
      t.string :cve_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :source

      t.timestamps null: false
    end
  end
end

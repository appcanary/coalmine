class CreateVulnerabilities < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerabilities do |t|
      t.references :advisory, null: false, index: true, foreign_key: true

      t.string :package_name, null: false, index: true
      t.string :package_platform, null: false, index: true
      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false
      
    
      t.timestamps null: false
    end
  end
end

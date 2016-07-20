class CreateVulnerableDependencies < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerable_dependencies do |t|
      t.references :vulnerability, null: false
      t.string :package_platform, null: false
      t.string :package_name, null: false

      t.string :affected_arches
      t.string :affected_releases

      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false

      t.timestamps null: false
    end


  end
end

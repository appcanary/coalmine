class CreateVulnerableDependencies < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerable_dependencies do |t|
      t.references :vulnerability, null: false, index: true
      t.string :platform, null: false, index: true
      t.string :release
      t.string :package_name, null: false, index: true
      t.string :arch

      t.text :patched_versions, array: true, :default => [], null: false
      t.text :unaffected_versions, array: true, :default => [], null: false

      t.boolean :pending, :default => false, null: false
      t.boolean :end_of_life, :default => :false, null: false

      t.timestamps null: false
    end

    add_index :vulnerable_dependencies, [:platform, :package_name]
  end
end

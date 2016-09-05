class CreateVulnerableDependencies < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerable_dependencies do |t|
      t.references :vulnerability, null: false
      t.string :package_platform, null: false
      t.string :package_name, null: false
      t.string :affected_release
      t.string :affected_arch

      # t.string :affected_arches, array: true, :default => [], null: false
      # t.string :affected_releases, array: true, :default => [], null: false

      t.text :patched, array: true, :default => [], null: false
      t.text :unaffected, array: true, :default => [], null: false

      t.boolean :pending, :default => false, null: false
      t.boolean :end_of_life, :default => :false, null: false

      t.timestamps null: false
    end


  end
end

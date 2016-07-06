class CreatePackages < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table(:packages) do |t|
      t.string :name, null: false
      t.string :source_name
      t.string :platform, null: false
      t.string :release
      t.string :version
      t.string :artifact
      t.string :platform
      t.string :epoch
      t.string :arch
      t.string :filename
      t.string :checksum
      t.string :origin

      t.timestamps null: false
    end

    add_index :packages, [:name, :version, :platform, :release]
  end
end

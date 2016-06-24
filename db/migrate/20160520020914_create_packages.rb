class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :source_name
      t.string :platform
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

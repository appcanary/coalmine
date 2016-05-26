class CreatePackagesPackageSets < ActiveRecord::Migration
  def change
    create_table :packages_package_sets do |t|
      t.references :package_set, index: true, foreign_key: true
      t.references :package, index: true, foreign_key: true
      t.boolean :vulnerable, null: false, default: false

      t.timestamps null: false
    end
  end
end

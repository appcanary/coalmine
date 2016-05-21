class CreatePackageSets < ActiveRecord::Migration
  def change
    create_table :package_sets do |t|
      t.references :pallet
      t.references :package
      t.boolean :vulnerable

      t.timestamps null: false
    end
  end
end

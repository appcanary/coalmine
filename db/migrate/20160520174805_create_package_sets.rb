class CreatePackageSets < ActiveRecord::Migration
  def change
    create_table :package_sets do |t|
      t.references :pallet, index: true, foreign_key: true
      t.references :package, index: true, foreign_key: true
      t.boolean :vulnerable, null: false, default: false

      t.timestamps null: false
    end
  end
end

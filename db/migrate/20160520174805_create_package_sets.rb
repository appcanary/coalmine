class CreatePackageSets < ActiveRecord::Migration
  def change
    create_table :package_sets do |t|
      t.reference :pallet_id
      t.reference :package_id
      t.boolean :vulnerable

      t.timestamps null: false
    end
  end
end

class CreateLogBundlePatches < ActiveRecord::Migration
  def change
    create_table :log_bundle_patches do |t|
      t.references :bundle, index: true
      t.references :package, index: true
      t.references :bundled_package, index: true
      t.references :vulnerability, index: true
      t.references :vulnerable_package, index: true

      t.timestamps null: false
    end

    add_index :log_bundle_patches, [:bundle_id, :package_id, :bundled_package_id, :vulnerability_id, :vulnerable_package_id], unique: true, name: "index_of_five_kings_LBP"
  end
end

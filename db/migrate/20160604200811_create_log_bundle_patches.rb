class CreateLogBundlePatches < ActiveRecord::Migration
  def change
    create_table :log_bundle_patches do |t|
      t.references :bundle, index: true, null: false
      t.references :package, index: true, null: false
      t.references :bundled_package, index: true, null: false
      t.references :vulnerability, index: true, null: false
      t.references :vulnerable_dependency, index: true, null: false
      t.references :vulnerable_package, index: true, null: false
      t.boolean :supplementary, null: false, default: false
      t.datetime :occurred_at, null: false

      t.timestamps null: false
    end

    add_index :log_bundle_patches, [:bundle_id, :package_id, :bundled_package_id, :vulnerability_id, :vulnerable_dependency_id, :vulnerable_package_id], unique: true, name: "index_of_six_kings_LBP"
  end
end

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
  end
end

class CreateLogBundlePatches < ActiveRecord::Migration
  def change
    create_table :log_bundle_patches do |t|
      t.references :bundle, index: true, foreign_key: true
      t.references :package, index: true, foreign_key: true
      t.references :bundled_package, index: true, foreign_key: true
      t.references :vulnerability, index: true, foreign_key: true
      t.references :vulnerable_package, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

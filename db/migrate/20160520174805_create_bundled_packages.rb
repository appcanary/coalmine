class CreateBundledPackages < ActiveRecord::Migration
  def change
    create_table :bundled_packages do |t|
      t.references :bundle, index: true, foreign_key: true
      t.references :package, index: true, foreign_key: true
      t.boolean :vulnerable, null: false, default: false

      t.timestamps null: false
    end
  end
end

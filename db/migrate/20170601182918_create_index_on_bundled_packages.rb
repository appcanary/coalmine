class CreateIndexOnBundledPackages < ActiveRecord::Migration
  def change
    add_index :bundled_packages, [:bundle_id, :package_id]
  end
end

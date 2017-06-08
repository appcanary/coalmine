class ChangeIndexOnIgnoredPackagesAndResolutions < ActiveRecord::Migration
  def change
    remove_index :ignored_packages, name: "ignored_packages_by_account_package_bundle_ids"
    add_index :ignored_packages, [:package_id, :account_id, :bundle_id], unique: true, name: "ignored_packages_by_account_package_bundle_ids"

    remove_index :log_resolutions, name: "index_logres_account_vulndeps"
    add_index :log_resolutions, [:package_id, :account_id, :vulnerable_dependency_id], unique: true, name: "index_logres_account_vulndeps"
  end
end

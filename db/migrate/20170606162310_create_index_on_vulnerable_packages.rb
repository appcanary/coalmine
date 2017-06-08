class CreateIndexOnVulnerablePackages < ActiveRecord::Migration
  def change
    add_index :vulnerable_packages, [:package_id, :vulnerable_dependency_id, :vulnerability_id], unique: true, :name => "index_vulnpackage_packages"
  end
end

class CreateLogBundleVulnerabilities < ActiveRecord::Migration
  def change
    create_table :log_bundle_vulnerabilities do |t|
      t.references :bundle, index: true, foreign_key: true
      t.references :package, index: true, foreign_key: true
      t.references :bundled_package, index: true, foreign_key: true
      t.references :vulnerability, index: true, foreign_key: true
      t.references :vulnerable_package, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :log_bundle_vulnerabilities, [:bundle_id, :package_id, :bundled_package_id, :vulnerability_id, :vulnerable_package_id], unique: true, name: "index_of_five_kings"
  end
end

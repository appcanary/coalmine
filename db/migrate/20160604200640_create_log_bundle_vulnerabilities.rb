class CreateLogBundleVulnerabilities < ActiveRecord::Migration
  def change
    create_table :log_bundle_vulnerabilities do |t|
      t.references :bundle, index: true, null: false
      t.references :package, index: true, null: false
      t.references :bundled_package, index: true, null: false
      t.references :vulnerability, index: true, null: false
      t.references :vulnerable_package, index: true, null: false
      t.datetime :occurred_at

      t.timestamps null: false
    end

    add_index :log_bundle_vulnerabilities, [:bundle_id, :package_id, :bundled_package_id, :vulnerability_id, :vulnerable_package_id], unique: true, name: "index_of_five_kings_LBV"
  end
end

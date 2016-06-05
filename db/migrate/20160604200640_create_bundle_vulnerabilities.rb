class CreateBundleVulnerabilities < ActiveRecord::Migration
  def change
    create_table :bundle_vulnerabilities do |t|
      t.references :bundle_id, index: true, foreign_key: true
      t.references :vulnerable_package_id, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

class CreateBundleVulnerabilities < ActiveRecord::Migration
  def change
    create_table :bundle_vulnerabilities do |t|
      t.references :bundle, index: true, foreign_key: true
      t.references :vulnerable_package, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

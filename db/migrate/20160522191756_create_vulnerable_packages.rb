class CreateVulnerablePackages < ActiveRecord::Migration
  def change
    create_table :vulnerable_packages do |t|
      t.references :package, index: true, foreign_key: true
      t.references :vulnerability, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

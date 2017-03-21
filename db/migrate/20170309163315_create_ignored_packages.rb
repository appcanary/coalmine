class CreateIgnoredPackages < ActiveRecord::Migration
  def change
    create_table :ignored_packages do |t|
      t.belongs_to :account, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :package, index: true, foreign_key: true, null: false

      t.belongs_to :bundle, index: true, foreign_key: true
      t.integer :criticality
      t.string :note

      t.timestamps null: false
    end

    add_index :ignored_packages, [:account_id, :package_id, :bundle_id], unique: true, name: "ignored_packages_by_account_package_bundle_ids"
  end
end

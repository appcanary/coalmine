class CreateIgnores < ActiveRecord::Migration
  def change
    create_table :ignores do |t|
      t.belongs_to :account, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.belongs_to :package, index: true, foreign_key: true, null: false

      t.belongs_to :bundle, index: true, foreign_key: true
      t.integer :criticality
      t.string :note

      t.timestamps null: false
    end

    add_index :ignores, [:account_id, :bundle_id, :package_id], unique: true
  end
end

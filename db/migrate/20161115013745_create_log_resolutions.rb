class CreateLogResolutions < ActiveRecord::Migration
  def change
    create_table :log_resolutions do |t|
      t.references :account, index: true, null: false
      t.references :user, index: true, null: false
      t.references :package, index: true, null: false
      t.references :vulnerability, index: true, null: false
      t.references :vulnerable_dependency, index: true, null: false
      t.string :note

      t.timestamps null: false
    end

    add_index :log_resolutions, [:account_id, :package_id, :vulnerable_dependency_id], unique: true, name: "index_logres_account_vulndeps"
    
  end
end

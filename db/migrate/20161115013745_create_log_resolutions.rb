class CreateLogResolutions < ActiveRecord::Migration
  def change
    create_table :log_resolutions do |t|
      t.references :account, index: true, null: false
      t.references :user, index: true, null: false
      t.references :vulnerability, index: true, null: false
      t.references :vulnerable_dependency, index: true, null: false
      t.string :note

      t.timestamps null: false
    end
  end
end

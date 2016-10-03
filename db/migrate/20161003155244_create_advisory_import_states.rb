class CreateAdvisoryImportStates < ActiveRecord::Migration
  def change
    create_table :advisory_import_states do |t|
      t.references :advisory, index: true, foreign_key: true
      t.boolean :processed, default: false, null: false

      t.timestamps null: false
    end
  end
end

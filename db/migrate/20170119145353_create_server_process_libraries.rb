class CreateServerProcessLibraries < ActiveRecord::Migration
  def change
    create_table :server_process_libraries do |t|
      t.references :server_process, index: true, foreign_key: true, null: false
      t.references :process_library, index: true, foreign_key: true, null: false

      t.boolean :outdated, default: false

      t.timestamps null: false
    end
  end
end

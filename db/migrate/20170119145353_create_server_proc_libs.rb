class CreateServerProcLibs < ActiveRecord::Migration
  def change
    create_table :server_proc_libs do |t|
      t.references :server_proc, index: true, foreign_key: true, null: false
      t.references :proc_lib, index: true, foreign_key: true, null: false

      t.boolean :outdated, default: false

      t.timestamps null: false
    end
  end
end

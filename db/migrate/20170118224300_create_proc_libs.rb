class CreateProcLibs < ActiveRecord::Migration
  def change
    create_table :proc_libs do |t|
      t.string :path
      t.datetime :modified
      t.string :package

      t.timestamps null: false
    end
  end
end

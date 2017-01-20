class CreateProcessLibraries < ActiveRecord::Migration
  def change
    create_table :process_libraries do |t|
      t.string :path
      t.datetime :modified
      t.string :package_name
      t.string :package_version

      t.timestamps null: false
    end
  end
end

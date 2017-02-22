class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.text :tag

      t.timestamps null: false
    end

    add_index :tags, :tag, :unique => true
  end
end

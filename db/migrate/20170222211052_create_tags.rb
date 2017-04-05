class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :account, index: true, foreign_key: true, null: false
      t.text :tag, index: true

      t.timestamps null: false
    end

    add_index :tags, [:account_id, :tag], :unique => true
  end
end

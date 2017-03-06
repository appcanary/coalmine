class CreateMotds < ActiveRecord::Migration
  def change
    create_table :motds do |t|
      t.references :user, foreign_key: true, null: false
      t.string :subject
      t.text :body, null: false
      t.datetime :remove_at, index: true, null: false
      t.string :position, default: "header"

      t.timestamps null: false
    end
  end
end

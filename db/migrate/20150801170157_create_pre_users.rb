class CreatePreUsers < ActiveRecord::Migration
  def change
    create_table :pre_users do |t|
      t.string :email

      t.timestamps null: false
    end
  end
end

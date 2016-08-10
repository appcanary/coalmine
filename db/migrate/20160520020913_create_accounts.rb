class CreateAccounts < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :accounts do |t|
      t.string :email, null: false
      t.string :token, null: false, index: true, unique: true

      t.timestamps null: false
    end
    add_index :accounts, :email, unique: true
  end
end

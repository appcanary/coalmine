class AddAccountToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :account, index: true, foreign_key: true
    User.find_each do |u|
      User.transaction do
        u.account = Account.create(:email => u.email)
        u.save!
      end
    end

    change_column_null :users, :account_id, false
  end
end

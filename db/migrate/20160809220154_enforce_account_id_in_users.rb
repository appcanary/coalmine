class EnforceAccountIdInUsers < ActiveRecord::Migration
  def change
    User.where(:email => "jkhkj@hvom").delete_all
    User.find_each do |u|
      u.account = Account.new(:id => u.id, :email => u.email)
      begin
        u.save!
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end
    end

    change_column_null :users, :account_id, false
  end
end

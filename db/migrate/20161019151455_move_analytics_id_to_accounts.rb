class MoveAnalyticsIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :datomic_id, :bigint
    User.includes(:account).find_each do |u|
      acct = u.account
      acct.update_column(:datomic_id, u.datomic_id)
    end
  end
end

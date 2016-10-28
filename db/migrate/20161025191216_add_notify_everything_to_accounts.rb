class AddNotifyEverythingToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :notify_everything, :boolean, default: false, null: false
  end
end

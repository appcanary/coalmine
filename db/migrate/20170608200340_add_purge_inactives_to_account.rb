class AddPurgeInactivesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :purge_inactive_servers, :bool, default: false
  end
end

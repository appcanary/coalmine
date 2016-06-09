class AddInvoidedToUser < ActiveRecord::Migration
  def change
    add_column :users, :invoiced_manually, :bool, :default => false, :nil => false
  end
end

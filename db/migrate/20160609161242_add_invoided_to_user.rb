class AddInvoidedToUser < ActiveRecord::Migration
  def change
    add_column :users, :invoiced, :bool
  end
end

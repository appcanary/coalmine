class AddFromIsitvulnToPreUser < ActiveRecord::Migration
  def change
    add_column :pre_users, :from_isitvuln, :bool, :default => false
  end
end

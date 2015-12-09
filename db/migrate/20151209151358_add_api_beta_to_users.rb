class AddApiBetaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_beta, :boolean, :null => false, :default => :false
  end
end

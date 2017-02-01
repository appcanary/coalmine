class AddOsPrefAndDeployPrefToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pref_os, :string
    add_column :users, :pref_deploy, :string
  end
end

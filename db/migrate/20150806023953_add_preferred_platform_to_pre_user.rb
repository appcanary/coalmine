class AddPreferredPlatformToPreUser < ActiveRecord::Migration
  def change
    add_column :pre_users, :preferred_platform, :string
  end
end

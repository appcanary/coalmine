class AddSubscriptionPlanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscription_plan, :string
  end
end

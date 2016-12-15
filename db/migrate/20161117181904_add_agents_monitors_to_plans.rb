class AddAgentsMonitorsToPlans < ActiveRecord::Migration
  def change
    rename_column :subscription_plans, :limit, :agent_limit
    rename_column :subscription_plans, :unit_value, :agent_value
    add_column :subscription_plans, :monitor_limit, :integer
    add_column :subscription_plans, :monitor_value, :integer
    add_column :subscription_plans, :user_limit, :integer , :default => 5
    add_column :subscription_plans, :api_limit, :integer, :default => 0
    add_column :subscription_plans, :free, :boolean, :default => false

    SubscriptionPlan.all.each do |s|
      s.monitor_limit = s.agent_limit
      s.monitor_value = s.agent_value
      s.save
    end
  end
end

class NoMoreMonitorValue < ActiveRecord::Migration
  def change
    remove_column :subscription_plans, :monitor_value, :int
    remove_column :subscription_plans, :monitor_limit, :int
    plan_updates = [["Indie", 2000],
                    ["Team", 1000],
                    ["Company", 600]]

    # Update the subscription plan values to match index
    plan_updates.each do |name, agent_value|
      s = SubscriptionPlan.find_by_label(name)
      s.agent_value = agent_value
      s.save!
    end

    # Update every users shown plans to be the new ones
    default_plans = SubscriptionPlan.where(default: true).order(:value).pluck(:id)
    BillingPlan.find_each do |b|
      b.available_subscription_plans = default_plans
      b.save!
    end
  end
end

class ChangeDefaultSubscriptionPlans < ActiveRecord::Migration
  # We've raised prices across the board
  def change
    # make all the existing ones not default
    SubscriptionPlan.where(:default => true).all.each do |s|
      s.default = false
      s.save
    end

    # New plans
    plans = [["Free",          0, 1, 1, 10, 1, true],
             ["Individual", 9900, 5, 5, 10, 1, false],
             ["Team",      49900, 50, 50, 500, 5, false],
             ["Startup",  299900, 500, 500, 5000, 1000, false]]
    plans.each do |name, price, agent_limit, monitor_limit, api_limit, user_limit, free|
      SubscriptionPlan.find_or_create_by(:label => name, :value => price, :agent_limit => agent_limit, :monitor_limit => monitor_limit, :api_limit => api_limit, :user_limit => user_limit, :agent_value => 2500, :monitor_value => 1500, :free => free, :default => true)
    end
  end
end

class ChangeDefaultSubscriptionPlans < ActiveRecord::Migration
  # We've raised prices across the board
  def change
    # make all the existing ones not default
    SubscriptionPlan.where(:default => true).update_all(:default => false)

    # New plans
    plans = [["Free",          0, 1, 1, 10, 1, true],
             ["Indie", 9900, 5, 5, 10, 1, false],
             ["Team",      49900, 50, 50, 500, 5, false],
             ["Company",  299900, 500, 500, 5000, 1000, false]]
    plans.each do |name, price, agent_limit, monitor_limit, api_limit, user_limit, free|
      SubscriptionPlan.find_or_create_by(:label => name) do |s|
        s.value = price
        s.agent_limit = agent_limit
        s.monitor_limit = monitor_limit
        s.api_limit = api_limit
        s.user_limit
        s.agent_value = 2500
        s.monitor_value = 1500
        s.free = free
        s.default = true
      end
    end
  end
end

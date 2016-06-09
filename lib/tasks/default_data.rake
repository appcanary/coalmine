namespace :db do
  desc "add default subscriptions"
  task :seed_subscriptions do


    default_plans = [[2900, 5, "- Up to 5 servers"],
                     [9900, 15, "- Up to 15 servers"],
                     [29900, 50, "- Up to 50 servers"]]
    default_unit_value = 900

    default_plans.each do |v, lm, lb|
      SubscriptionPlan.find_or_create_by(:value => v, :unit_value => default_unit_value, :limit => lm, :label => lb, :default => true)
    end

    default_discount = [[2300, 5, "- Up to 5 servers"],
                        [7900, 15, "- Up to 15 servers"],
                        [23900, 50, "- Up to 50 servers"]]

    default_discount.each do |v, lm, lb|
      SubscriptionPlan.find_or_create_by(:value => v, :unit_value => default_unit_value, :limit => lm, :label => lb, :discount => true)
    end
  end
end



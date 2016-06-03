class SwitchOldSubscriptionPlans < ActiveRecord::Migration
  def change
    # Given on prod as of 2016/06/03
    # User.where("stripe_customer_id is not null and subscription_plan is not null").distinct("subscription_plan").pluck("subscription_plan")
    # => ["$299/month", "$99/month", "$23/month", "$29/month", "$79/month", "$239/month"]
    #
    # let's build a map of existing value to subscription:

    hsh = ["$299/month", "$99/month", "$23/month", "$29/month", "$79/month", "$239/month"].reduce({}) do |h, s| 
      v = s.match(/[0-9]+/).to_s; 
      h[s] = SubscriptionPlan.where(:value => "#{v}00").first; 
      h
    end

    User.where("stripe_customer_id is not null and subscription_plan is not null").find_each do |user|
      # and change people's subscriptions accordingly
      # this should work because billing_plan is smart enough
      # to instantiate the discount plans if someone has a discount
      # and the rest is a matter of assigning the right discounted plan
      bm = BillingManager.new(user)
      user = bm.change_subscription!(hsh[user.subscription_plan])
      user.save!
    end
  end
end

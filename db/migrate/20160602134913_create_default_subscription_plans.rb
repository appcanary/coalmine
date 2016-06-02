class CreateDefaultSubscriptionPlans < ActiveRecord::Migration
  def change
    Rake::Task['db:seed_subscriptions'].invoke
  end
end

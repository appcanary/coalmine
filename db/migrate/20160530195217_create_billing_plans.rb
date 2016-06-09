class CreateBillingPlans < ActiveRecord::Migration
  def change
    create_table :billing_plans do |t|
      t.references :user, index: true, foreign_key: true
      t.references :subscription_plan, index: true, foreign_key: true
      t.integer :available_subscription_plans, array: true, default: []
      t.datetime :started_at

      t.timestamps null: false
    end
  end
end

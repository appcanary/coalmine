class CreateBillingPlans < ActiveRecord::Migration
  def change
    create_table :billing_plans do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :current_plan_value
      t.integer :current_plan_unit_value
      t.integer :current_plan_limit
      t.integer :current_plan_label
      t.integer :plan_values, array: true, default: []
      t.integer :plan_unit_values, array: true, default: []
      t.integer :plan_limits, array: true, default: []
      t.string :plan_labels, array: true, default: []

      t.timestamps null: false
    end
  end
end

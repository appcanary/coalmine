class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.integer :value
      t.integer :unit_value
      t.integer :limit
      t.string :label
      t.string :comment
      t.boolean :default, :default => false, :null => false, :index => true
      t.boolean :discount, :default => false, :null => false, :index => true

      t.timestamps null: false
    end
  end
end

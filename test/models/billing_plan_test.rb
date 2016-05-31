# == Schema Information
#
# Table name: billing_plans
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  current_plan_value      :integer
#  current_plan_unit_value :integer
#  current_plan_limit      :integer
#  current_plan_label      :string
#  plan_values             :integer          default("{}"), is an Array
#  plan_unit_values        :integer          default("{}"), is an Array
#  plan_limits             :integer          default("{}"), is an Array
#  plan_labels             :string           default("{}"), is an Array
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_billing_plans_on_user_id  (user_id)
#

require 'test_helper'

class BillingPlanTest < ActiveSupport::TestCase
  it "should generate default values" do
    bplan = BillingPlan.new
    assert_equal bplan.subscriptions.count, 3
    assert_equal bplan.current_subscription, BillingPlan.default_subscriptions.first
  end

  it "should load and unload subscriptions" do
    bplan = BillingPlan.new
    test_sub_value = 123000
    new_sub = BillingPlan::Subscription.new(test_sub_value, "test sub", 1000, 10)
    bplan.current_subscription = new_sub
    assert bplan.save

    bplan.reload
    assert_equal bplan.subscriptions.count, 4
    assert_equal bplan.current_plan_value, test_sub_value
  end
end

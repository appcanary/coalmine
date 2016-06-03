# == Schema Information
#
# Table name: subscription_plans
#
#  id         :integer          not null, primary key
#  value      :integer
#  unit_value :integer
#  limit      :integer
#  label      :string
#  comment    :string
#  default    :boolean          default("false"), not null
#  discount   :boolean          default("false"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subscription_plans_on_default   (default)
#  index_subscription_plans_on_discount  (discount)
#

require 'test_helper'

class SubscriptionPlanTest < ActiveSupport::TestCase
  test "that we calculate the monthly cost correctly" do

    sub = SubscriptionPlan.new(:value => 1000,
                               :unit_value => 100,
                               :limit => 10)

    assert_equal sub.cost(0), 10
    assert_equal sub.cost(1), 10
    assert_equal sub.cost(10), 10
    assert_equal sub.cost(11), 11
    assert_equal sub.cost(20), 20
  end
end

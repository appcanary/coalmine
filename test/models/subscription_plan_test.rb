# == Schema Information
#
# Table name: subscription_plans
#
#  id            :integer          not null, primary key
#  value         :integer
#  agent_value   :integer
#  agent_limit   :integer
#  label         :string
#  comment       :string
#  default       :boolean          default("false"), not null
#  discount      :boolean          default("false"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  monitor_limit :integer
#  monitor_value :integer
#  user_limit    :integer          default("5")
#  api_limit     :integer          default("0")
#  free          :boolean          default("false")
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
                               :agent_value => 100,
                               :agent_limit => 10,
                               :monitor_value => 200,
                               :monitor_limit => 10)

    assert_equal sub.cost(0,0), 1000
    assert_equal sub.cost(1,1), 1000
    assert_equal sub.cost(10,10), 1000
    assert_equal sub.cost(11,10), 1100
    assert_equal sub.cost(10,11), 1200
  end
end

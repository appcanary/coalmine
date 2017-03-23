# == Schema Information
#
# Table name: subscription_plans
#
#  id          :integer          not null, primary key
#  value       :integer
#  agent_value :integer
#  agent_limit :integer
#  label       :string
#  comment     :string
#  default     :boolean          default("false"), not null
#  discount    :boolean          default("false"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_limit  :integer          default("5")
#  api_limit   :integer          default("0")
#  free        :boolean          default("false")
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
                               :agent_limit => 10)
    
    assert_equal 1000, sub.cost(0,0)
    assert_equal 1000, sub.cost(1,1)
    assert_equal 1000, sub.cost(5,5)
    assert_equal 1100, sub.cost(5,6)
    assert_equal 1100, sub.cost(6,5)
  end
end

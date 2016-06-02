# == Schema Information
#
# Table name: subscription_plans
#
#  id         :integer          not null, primary key
#  value      :integer
#  unit_value :integer
#  limit      :integer
#  label      :string
#  default    :boolean          default("false"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subscription_plans_on_default  (default)
#

require 'test_helper'

class SubscriptionPlanTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

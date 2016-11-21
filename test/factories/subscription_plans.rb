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

FactoryGirl.define do
  factory :subscription_plan do
    value 1
    agent_value 1
    monitor_value 1
    agent_limit 1
    monitor_limit 1
    label "MyString"
    default false
  end
end

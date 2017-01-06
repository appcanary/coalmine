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

FactoryGirl.define do
  factory :subscription_plan do
    value 1
    agent_value 1
    agent_limit 1
    label "MyString"
    default false
  end
end

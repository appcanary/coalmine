# == Schema Information
#
# Table name: billing_plans
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subscription_plan_id         :integer
#  available_subscription_plans :integer          default("{}"), is an Array
#  started_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_billing_plans_on_subscription_plan_id  (subscription_plan_id)
#  index_billing_plans_on_user_id               (user_id)
#

FactoryGirl.define do
  factory :billing_plan do
    monthly_value "9.99"
    agent_value "9.99"
    plan_labels ""
    plan_values ""
  end

end

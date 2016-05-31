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

FactoryGirl.define do
  factory :billing_plan do
    monthly_value "9.99"
    unit_value "9.99"
    plan_labels ""
    plan_values ""
  end

end

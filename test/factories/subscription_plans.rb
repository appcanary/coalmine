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

FactoryGirl.define do
  factory :subscription_plan do
    value 1
unit_value 1
limit 1
label "MyString"
default false
  end

end

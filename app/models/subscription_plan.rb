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

class SubscriptionPlan < ActiveRecord::Base
  scope :default_plans, -> { where(:default => true) }

  def value_in_currency
    value / 100
  end

  def text
    "$#{self.value_in_currency}/month #{label}".strip
  end

  def cost(app_count)
    app_cost = (([app_count, limit].max - limit) * unit_value) 
    (value + app_cost).to_f / 100
  end
end

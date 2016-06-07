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

class SubscriptionPlan < ActiveRecord::Base
  scope :default_plans, -> { where(:default => true) }
  scope :default_discount, -> { where(:discount => true) }

  def value_in_currency
    value / 100
  end

  def text
    "$#{self.value_in_currency}/month #{label}".strip
  end

  def cost(app_count)
    app_cost = (([app_count, limit].max - limit) * unit_value) 
    value + app_cost
  end
end

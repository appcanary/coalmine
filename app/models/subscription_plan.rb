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

  def agent_value_in_currency
    agent_value / 100
  end

  def monitor_value_in_currency
    monitor_value / 100
  end

  def text
    if agent_limit == 0
      "$#{self.agent_value_in_currency}/server/month #{label}".strip
    else
      "$#{self.value_in_currency}/month #{label}".strip
    end
  end

  def cost(agents, monitors)
    agent_cost = (([agents, agent_limit].max - agent_limit) * agent_value)
    monitor_cost = (([monitors, monitor_limit].max - monitor_limit) * monitor_value) 
    value + agent_cost + monitor_cost
  end
end

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
#  user_limit    :integer          default("5")
#  api_limit     :integer          default("0")
#  free          :boolean          default("false")
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
    value / 100.0
  end

  def agent_value_in_currency
    agent_value / 100.0
  end

  def text
    if agent_limit == 0
      "$#{self.agent_value_in_currency}/agent/month #{label}".strip
    else
      "$#{self.value_in_currency}/month #{label}".strip
    end
  end

  def cost(agents, monitors)
    total_items = agents + monitors
    value + (([total_items, agent_limit].max - agent_limit) * agent_value)
  end
end

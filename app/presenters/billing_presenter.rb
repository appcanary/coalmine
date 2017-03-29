# class whose sole purpose is to wrap BillingPlan 
# objects and provide an interface for interacting
# with the html/form renderer - rather than saddling
# BillingPlan or BillingManager with this responsibility

class BillingPresenter
  include ActionView::Helpers::NumberHelper

  CANCEL = "Cancel subscription"

  attr_accessor :user, :billing_plan, :show_cancel
  delegate :monthly_cost, :to => :billing_plan

  def initialize(billing_plan)
    self.billing_plan = billing_plan
  end

  def current_plan
    self.billing_plan.subscription_plan
  end

  def select_plans
    plans = self.billing_plan.subscription_plans.map { |s| [s.text, s.id] }

    # Only show cancel if we have a selected plan
    if self.current_plan.present?
      [CANCEL] + plans
    else
      plans
    end
  end

  def selected_plan
    if self.current_plan
      [current_plan.text, current_plan.id]
    end
  end

  def disabled_plans(active_servers_count, monitors_count)
    billing_plan.subscription_plans.select { |s| (s.agent_limit < active_servers_count + monitors_count) && (s.agent_limit != 0) }.map(&:id)
  end

  def monthly_cost_in_dollars
    number_to_currency(billing_plan.monthly_cost.to_f / 100)
  end

end

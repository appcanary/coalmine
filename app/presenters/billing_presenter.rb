# class whose sole purpose is to wrap BillingPlan 
# objects and provide an interface for interacting
# with the html/form renderer - rather than saddling
# BillingPlan or BillingManager with this responsibility

class BillingPresenter
  CANCEL = "Cancel subscription"

  attr_accessor :user, :billing_plan, :show_cancel

  def initialize(billing_plan, show_cancel)
    self.billing_plan = billing_plan

    self.show_cancel = show_cancel
  end

  def select_plans
    plans = self.billing_plan.subscription_plans.map { |s| [s.text, s.id] }

    if self.show_cancel
      [CANCEL] + plans
    else
      plans
    end
  end

  def selected_plan
    cs = self.billing_plan.subscription_plan
    if cs
      [cs.text, cs.id]
    end
  end

  def disabled_plans(servers_count, monitors_count)
    total = servers_count + monitors_count
    billing_plan.subscription_plans.select { |s| (s.limit < total) && (s.limit != 0) }.map(&:id)
  end

end

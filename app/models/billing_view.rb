class BillingView
  CANCEL = "Cancel subscription"

  attr_accessor :user, :billing_plan, :show_cancel
  def initialize(billing_plan, show_cancel)
    self.billing_plan = billing_plan

    self.show_cancel = show_cancel
  end

  def select_plans
    plans = self.billing_plan.subscriptions.map { |s| [s.text, s.ident] }

    if self.show_cancel
      [CANCEL] + plans
    else
      plans
    end
  end

  def selected_plan
    cs = self.billing_plan.current_subscription
    [cs.text, cs.ident]
  end

  def disabled_plans
    
  end
end

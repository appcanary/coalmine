class SubscriptionPlan
  CANCEL = "Cancel subscription"
  AC_STARTER = "$29/month"
  AC_MIDDLE = "$99/month"
  AC_BIG = "$299/month"

  AC_DISCOUNT_STARTER = "$23/month"
  AC_DISCOUNT_MIDDLE = "$79/month"
  AC_DISCOUNT_BIG = "$239/month"

  
  RR_GOLD = "$5,000/month"

  AC_PLANS = [
    AC_STARTER,
    AC_MIDDLE,
    AC_BIG
  ]

  AC_DISCOUNT_PLANS = [
    AC_DISCOUNT_STARTER,
    AC_DISCOUNT_MIDDLE,
    AC_DISCOUNT_BIG,
  ]

  RR_PLANS = [ RR_GOLD ]

  ALL_PLANS = AC_PLANS + RR_PLANS


  def self.ac_plans
    AC_PLANS
  end

  def self.all_plans
    [CANCEL] + ALL_PLANS
  end

  def self.discount_plans
    [CANCEL] + AC_DISCOUNT_PLANS
  end

  def self.disabled_ac_plan(server_count, discount = false)
    if discount
      starter = AC_DISCOUNT_STARTER
      middle = AC_DISCOUNT_MIDDLE
    else
      starter = AC_STARTER
      middle = AC_MIDDLE
    end

    case server_count
    when 6..15
      [starter]
    when 16..50
      [starter, middle]
    end
  end

  def self.select_ac_plans(show_cancel = false, discount = false)
    if discount
      plans = AC_DISCOUNT_PLANS
    else
      plans = AC_PLANS
    end

    if show_cancel
      ([CANCEL] + plans).map { |p| wrap_plan_label(p) }
    else
      (plans).map { |p| wrap_plan_label(p) }
    end
  end

  def self.current_plan(plan)
    if all_plans.include?(plan)
      plan
    else
      "custom"
    end
  end

  def self.plan_label(plan)
    case plan
    when AC_STARTER
      "Up to 5 servers"
    when AC_MIDDLE
      "Up to 15 servers"
    when AC_BIG
      "Up to 50 servers"
    when AC_DISCOUNT_STARTER
      "Up to 5 servers"
    when AC_DISCOUNT_MIDDLE
      "Up to 15 servers"
    when AC_DISCOUNT_BIG
      "Up to 50 servers"
    when RR_GOLD
      "Gold Ruby Review Sponsor"
    when CANCEL
      nil
    else
      "custom"
    end
  end

  def self.wrap_plan_label(p)
    label = [p, plan_label(p)].compact

    [label.join(" - "), p]
  end
end

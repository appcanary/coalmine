# == Schema Information
#
# Table name: billing_plans
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subscription_plan_id         :integer
#  available_subscription_plans :integer          default("{}"), is an Array
#  started_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_billing_plans_on_subscription_plan_id  (subscription_plan_id)
#  index_billing_plans_on_user_id               (user_id)
#

class BillingPlan < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscription_plan
 
  # perhaps the only reasonable uses of these methods
  # the 'subscriptions' ivar won't get saved unless
  # we explicitly serialize it.
  after_initialize :set_defaults
  before_save :serialize_subscriptions

  attr_accessor :subscription_plans

  def subscription_plans
    @subscription_plans ||= load_subscriptions
  end

  def reset_subscription
    self.subscription_plan = nil
  end

  def monthly_cost
    if cur_sub = self.subscription_plan
      cur_sub.cost(user.servers_count + user.monitors_count)
    else
      0
    end
  end


  private
  def set_defaults
    # calling #subscriptions will deserialize the
    # existing fields. if it returns an empty value,
    # then let's load the default subscriptions.
    unless self.subscription_plans.present?
      if self.user.discounted?
        self.subscription_plans = SubscriptionPlan.default_discount
      else
        self.subscription_plans = SubscriptionPlan.default_plans
      end
    end
  end

  def load_subscriptions
    SubscriptionPlan.where(:id => available_subscription_plans)
  end

  # Serialize the default subscriptions to the database on save.
  # If avail_subs is empty (init or deleted) then we should populate
  # with the defaults.
  #
  # however, if we directly change the avail_sub_plans we don't want
  # our intentional change to be overwritten.
  def serialize_subscriptions
    unless available_subscription_plans_changed?
      self.available_subscription_plans = self.subscription_plans.map(&:id)
    end
  end

end

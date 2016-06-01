# == Schema Information
#
# Table name: billing_plans
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  current_plan_value      :integer
#  current_plan_unit_value :integer
#  current_plan_limit      :integer
#  current_plan_label      :string
#  plan_values             :integer          default("{}"), is an Array
#  plan_unit_values        :integer          default("{}"), is an Array
#  plan_limits             :integer          default("{}"), is an Array
#  plan_labels             :string           default("{}"), is an Array
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_billing_plans_on_user_id  (user_id)
#

class BillingPlan < ActiveRecord::Base
  belongs_to :user
 
  # perhaps the only reasonable uses of these methods
  # the 'subscriptions' ivar won't get saved unless
  # we explicitly serialize it.
  after_initialize :set_defaults
  before_save :serialize_subscriptions

  attr_accessor :subscriptions

  # Subscriptions are abstractions over the four 
  # variables we keep track of to calculate how much
  # we invoice people for.
  #
  # A user may have one subscription at a given time,
  # but they are provided with a list of options.
  #
  # They are charged one 'value' per month, for up to
  # a 'limit' or units. If they exceed that limit, they
  # are charged a 'unit_value' for every unit in excess.
  # Finally, we provide a label for describing the
  # subscription.
  #
  # At first I thought of modelling this as a normal database
  # table - SubscriptionPlans. I settled on this weird 
  # serialization format because at the time it seemed "simpler":
  # a "quick" hack that lets us set a list of custom subscriptions 
  # for any given user, tho now I am not so sure.
  #
  # In principle, this should make grandfathering people
  # straightforward - all the information is stored in this
  # one database row.
  #
  # On the plus side, ripping this out into its own table in
  # the future should be straightforward.
  class Subscription
    attr_accessor :value, :unit_value, :limit, :label
    def initialize(v, uv, lm, lb)
      self.value = v
      self.unit_value = uv
      self.limit = lm
      self.label = lb
    end

    def value_in_currency
      value / 100
    end

    def text
      "$#{self.value_in_currency}/month #{label}".strip
    end

    def vars
      [value, unit_value, limit, label]
    end

    def ident
      @ident ||= Digest::MD5.hexdigest(vars.join)
    end

    # used for all sorts of comparisons,
    # what simpler way than the md5 hsh?
    def ==(sub)
      self.ident == sub.ident
    end
  end

  def subscriptions
    @subscriptions ||= load_subscriptions
  end

  def current_subscription
    if current_plan_value
      Subscription.new(current_plan_value, current_plan_unit_value, 
                       current_plan_limit, current_plan_label)
    end
  end

  def current_subscription=(sub)
    self.current_plan_value = sub.value
    self.current_plan_unit_value = sub.unit_value
    self.current_plan_limit = sub.limit
    self.current_plan_label = sub.label

    # if this subscription doesn't already exist in our
    # list of subscrpitions, then let's add it.
    # maybe this should be validated instead but eh:

    unless subscriptions.include?(sub)
      subscriptions << sub
    end
    sub
  end

  def reset_current_subscription
    self.current_plan_value = nil
    self.current_plan_unit_value = nil
    self.current_plan_limit = nil
    self.current_plan_label = nil
  end

  def self.default_subscriptions
    BillingManager::DEFAULT_PLANS.map do |v, lm, lb|
      Subscription.new(v, BillingManager::DEFAULT_UNIT_VALUE, lm, lb)
     end
  end

  private
  def set_defaults
    # calling #subscriptions will deserialize the
    # existing fields. if it returns an empty value,
    # then let's load the default subscriptions.
    unless self.subscriptions.present?
      self.subscriptions = BillingPlan.default_subscriptions
    end

    unless current_subscription
      self.current_subscription = self.subscriptions.first
    end
  end

  # deserialize subscriptions from our silly little format
  def load_subscriptions
    self.plan_values.each_with_index.map do |pv, index|
      Subscription.new(pv, plan_unit_values[index], plan_limits[index], plan_labels[index])
    end
  end

  def serialize_subscriptions
    values = []
    unit_values = []
    labels = []
    limits = []

    self.subscriptions.each do |sub|
      values << sub.value
      unit_values << sub.unit_value
      limits << sub.limit
      labels << sub.label
    end

    self.plan_values = values
    self.plan_unit_values = unit_values
    self.plan_limits = limits
    self.plan_labels = labels
  end

end

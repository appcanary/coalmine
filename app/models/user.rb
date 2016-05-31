# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string           not null
#  crypted_password                :string
#  salt                            :string
#  created_at                      :datetime
#  updated_at                      :datetime
#  reset_password_token            :string
#  reset_password_token_expires_at :datetime
#  reset_password_email_sent_at    :datetime
#  activation_state                :string
#  activation_token                :string
#  activation_token_expires_at     :datetime
#  last_login_at                   :datetime
#  last_logout_at                  :datetime
#  last_activity_at                :datetime
#  last_login_from_ip_address      :string
#  failed_logins_count             :integer          default("0")
#  lock_expires_at                 :datetime
#  unlock_token                    :string
#  token                           :string
#  onboarded                       :boolean          default("false")
#  is_admin                        :boolean          default("false"), not null
#  beta_signup_source              :string
#  stripe_customer_id              :string
#  name                            :string
#  subscription_plan               :string
#  newsletter_email_consent        :boolean          default("true"), not null
#  api_beta                        :boolean          default("false"), not null
#  marketing_email_consent         :boolean          default("true"), not null
#  daily_email_consent             :boolean          default("false"), not null
#  datomic_id                      :integer
#
# Indexes
#
#  index_users_on_activation_token                     (activation_token)
#  index_users_on_email                                (email) UNIQUE
#  index_users_on_last_logout_at_and_last_activity_at  (last_logout_at,last_activity_at)
#  index_users_on_reset_password_token                 (reset_password_token)
#  index_users_on_unlock_token                         (unlock_token)
#

class User < ActiveRecord::Base
  authenticates_with_sorcery!
  validates :password, length: { minimum: 6 }, :if => :password
  validates_confirmation_of :password, :if => :password
  validates :email, uniqueness: true, presence: true, format: { with: /.+@.+\..+/i, message: "is not a valid address." }
  validate :correct_subscription_plan?
  validate :absence_of_stripe_errors

  has_one :billing_plan

  attr_accessor :stripe_errors, :servers_count, :active_servers_count, :api_calls_count

  def self.all_from_api(order = "created_at DESC")
    api_users = Backend.all_users.reduce({}) do |hsh, usr|
      hsh.tap { |h| h.store(usr["id"], usr) }
    end

    all_users = self.order(order)
    all_users.each do |u|
      u.servers_count = api_users[u.datomic_id]["server-count"]
      u.active_servers_count = api_users[u.datomic_id]["active-server-count"]
      u.api_calls_count = api_users[u.datomic_id]["api-calls-count"]
    end
  end

  def stripe_errors
    @stripe_errors ||= []
  end

  def servers
    @servers ||= Server.find_all(self)
  end

  def active_servers
    servers.reject(&:gone_silent?)
  end

  def servers_count
    @servers_count ||= api_info["server-count"]
  end

  def active_servers_count
    @active_servers_count ||= api_info["active-server-count"]
  end

  def monitors_count
    @monitors_count ||= api_info["monitored-app-count"]
  end

  def api_calls_count
    @api_calls_count ||= api_info["api-calls-count"]
  end

  def api_info
    @api_info ||= canary.get('users/me')
  end

  def agent_token
    api_info["agent-token"]
  end

  def stripe_customer
    if stripe_customer_id
      Billing.find_customer(self)
    end
  end

  def has_billing?
    stripe_customer_id.present?
  end

  def payment_info
    if has_billing?
      stripe_customer.sources
    else 
      []
    end
  end

  def discounted?
    beta_signup_source.present?
  end

  def correct_subscription_plan?
    unless valid_subscription?
      self.errors.add(:subscription_plan, "is not valid.")
    end
  end

  def valid_subscription?
    if self.subscription_plan.nil?
      # can't reset subscription plan
      # if we have a cc
      if has_billing?
        false
      else
        true
      end
    else
      if discounted?
        DeprecatedSubscriptionPlan.discount_plans.include? self.subscription_plan
      else
        DeprecatedSubscriptionPlan.all_plans.include? self.subscription_plan
      end
    end
  end


  # def delete_api_user!
  #   canary.delete_user
  # end

  protected
  def canary
    @canary ||= CanaryClient.new(self.token)
  end

  def absence_of_stripe_errors
    if @stripe_errors.present?
      @stripe_errors.each do |e|
        self.errors.add(:base, e)
      end
      false
    else
      true
    end
  end

  # when a password gets reset, the default sorcery 
  # action doesn't reset reset_password_email_sent_at
  # this is a problem because: if you reset, and change pw
  # you can't re-reset your pw until the time period expires.
  def clear_reset_password_token
    config = sorcery_config
    self.send(:"#{config.reset_password_token_attribute_name}=", nil)
    self.send(:"#{config.reset_password_token_expires_at_attribute_name}=", nil) if config.reset_password_expiration_period
    self.reset_password_email_sent_at = nil
  end
end

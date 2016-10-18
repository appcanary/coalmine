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
#  invoiced_manually               :boolean          default("false")
#  account_id                      :integer          not null
#
# Indexes
#
#  index_users_on_account_id                           (account_id)
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
  validate :absence_of_stripe_errors

  # autosave: true is important for making sure
  # this association gets persisted by user.save calls
  has_one :billing_plan, autosave: true

  # ---- parent account association
  belongs_to :account, autosave: true
  validates_presence_of :account
  validates_associated :account

  has_many :agent_servers, :through => :account
  has_many :bundles, :through => :account

  # TODO: eliminate token field from users table
  # TODO: eliminate agent_token
  delegate :token, :to => :account

  attr_accessor :stripe_errors, :servers_count, :active_servers_count, :api_calls_count, :monitors_count

  def stripe_errors
    @stripe_errors ||= []
  end

  def active_servers
    @active_servers ||= self.agent_servers.reject(&:gone_silent?)
  end

  def active_servers_count
    @active_servers_count ||= self.active_servers.count
  end

  def monitors_count
    @monitors_count ||= self.bundles.via_api.count
  end

  def api_calls_count
    @api_calls_count ||= 0 #api_info["api-calls-count"]
  end

  def stripe_customer
    if stripe_customer_id
      BillingManager.find_customer(self)
    end
  end

  def has_billing?
    invoiced_manually? || stripe_customer_id.present?
  end

  def payment_info
    if stripe_customer_id.present?
      stripe_customer.sources
    else 
      []
    end
  end

  def discounted?
    beta_signup_source.present?
  end

  def trial_remaining
    14 - (Time.zone.now - created_at).to_i / 1.day
  end

  def analytics_id
    self.datomic_id || self.id
  end

  protected
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

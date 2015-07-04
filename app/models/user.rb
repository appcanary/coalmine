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
  validates_confirmation_of :password
  validates :password, length: { minimum: 6 }, :if => :password
  validates_confirmation_of :password, :if => :password
  validates :email, uniqueness: true

  def servers
    @servers ||= canary.servers
  end

  def active_servers
    servers.reject(&:gone_silent?)
  end

  def server(id)
    canary.server(id)
  end

  def api_info
    canary.me
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

  protected
  def canary
    @canary ||= Canary.new(self.token)
  end
end

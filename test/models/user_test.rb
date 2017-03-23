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
#  agent_token                     :string
#  account_id                      :integer          not null
#  pref_os                         :string
#  pref_deploy                     :string
#  pref_tech                       :string           is an Array
#  phone_number                    :string
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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

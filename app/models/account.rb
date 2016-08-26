# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#  index_accounts_on_token  (token)
#

class Account < ActiveRecord::Base
  has_secure_token :token

  has_many :agent_servers

  has_many :bundles
  has_many :log_bundle_vulnerabilities, :through => :bundles
  has_many :log_bundle_patches, :through => :bundles
  has_many :log_api_calls

  has_many :email_messages
  has_many :email_patcheds
  has_many :email_vulnerables
  has_many :patched_notifications, :through => :email_patcheds, :source => :notifications
  has_many :vulnerable_notifications, :through => :email_vulnerables, :source => :notifications

  has_many :users


  validates :email, uniqueness: true, presence: true, format: { with: /.+@.+\..+/i, message: "is not a valid address." }

end

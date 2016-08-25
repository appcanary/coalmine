# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#

class Account < ActiveRecord::Base
  has_secure_token :token

  has_many :agent_servers

  has_many :bundles
  has_many :log_bundle_vulnerabilities, :through => :bundles
  has_many :log_bundle_patches, :through => :bundles
  has_many :log_api_calls

  has_many :users


  validates :email, uniqueness: true, presence: true, format: { with: /.+@.+\..+/i, message: "is not a valid address." }

end

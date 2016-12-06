# == Schema Information
#
# Table name: accounts
#
#  id                :integer          not null, primary key
#  email             :string           not null
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  datomic_id        :integer
#  notify_everything :boolean          default("false"), not null
#
# Indexes
#
#  index_accounts_on_email  (email) UNIQUE
#  index_accounts_on_token  (token)
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

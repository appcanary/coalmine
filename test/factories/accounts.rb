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

FactoryGirl.define do
  factory :account do
    sequence :email do |n|
      "alice#{n}@example.com"
    end
  end
end

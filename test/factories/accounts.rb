# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :account do
    sequence :email do |n|
      "alice#{n}@example.com"
    end
  end
end

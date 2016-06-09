# == Schema Information
#
# Table name: pre_users
#
#  id                 :integer          not null, primary key
#  email              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  preferred_platform :string
#  from_isitvuln      :boolean          default("false")
#  source             :string           default("unassigned"), not null
#

FactoryGirl.define do
  factory :pre_user do
    email "MyString"
  end

end

# == Schema Information
#
# Table name: is_it_vuln_results
#
#  id         :integer          not null, primary key
#  ident      :string           not null
#  result     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_is_it_vuln_results_on_ident  (ident)
#

FactoryGirl.define do
  factory :is_it_vuln_result do
    ident "MyString"
result "MyText"
  end

end
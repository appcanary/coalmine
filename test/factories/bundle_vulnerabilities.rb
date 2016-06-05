# == Schema Information
#
# Table name: bundle_vulnerabilities
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer
#  vulnerable_package_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

FactoryGirl.define do
  factory :bundle_vulnerability do
    bundle_id nil
    vulnerable_package_id nil
  end
end

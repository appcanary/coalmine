# == Schema Information
#
# Table name: vulnerabilities
#
#  id                  :integer          not null, primary key
#  package_name        :string           not null
#  package_platform    :string           not null
#  title               :string
#  reported_at         :datetime
#  description         :text
#  criticality         :string
#  patched_versions    :text             default("{}"), is an Array
#  unaffected_versions :text             default("{}"), is an Array
#  cve_id              :string
#  osvdb_id            :string
#  usn_id              :string
#  dsa_id              :string
#  rhsa_id             :string
#  cesa_id             :string
#  source              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#

require File.join(Rails.root, "test/factories", 'factory_helper')

FactoryGirl.define do

  sequence :package_name do |n|
    "#{Faker::Hacker.ingverb}##{n}"
  end

  sequence :cve_id do |n|
    "CVE-9999-$04d" % n
  end

  factory :vulnerability do
    package_name { generate(:package_name) }
    package_platform { FactoryHelper.rand_platform }
    cve_id { generate(:cve_id) }

    factory :ruby_vulnerability do
      package_platform Platforms::Ruby
    end
  end
end

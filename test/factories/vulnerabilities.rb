# == Schema Information
#
# Table name: vulnerabilities
#
#  id                  :integer          not null, primary key
#  package_name        :string
#  package_platform    :string
#  title               :string
#  reported_at         :datetime
#  description         :text
#  criticality         :string
#  patched_versions    :text
#  unaffected_versions :text
#  cve_id              :string
#  usn_id              :string
#  dsa_id              :string
#  rhsa_id             :string
#  cesa_id             :string
#  source              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require File.join(Rails.root, "test/factories", 'factory_helper')

FactoryGirl.define do
  sequence :cve_id do |n|
    "CVE-9999-$04d" % n
  end

  factory :vulnerability do
    package_name { Faker::Hacker.ingverb }
    package_platform { FactoryHelper.rand_platform }
    cve_id { generate(:cve_id) }

    factory :ruby_vulnerability do
      package_platform Platforms::Ruby
    end
  end
end

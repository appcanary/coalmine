# == Schema Information
#
# Table name: vulnerabilities
#
#  id                  :integer          not null, primary key
#  package_platform    :string           not null
#  package_names       :string           default("{}"), not null, is an Array
#  affected_arches     :string           default("{}"), not null, is an Array
#  affected_releases   :string           default("{}"), not null, is an Array
#  patched_versions    :jsonb            default("{}"), not null
#  unaffected_versions :jsonb            default("{}"), not null
#  title               :string
#  description         :text
#  criticality         :string
#  cve_ids             :string           default("{}"), not null, is an Array
#  osvdb_id            :string
#  usn_id              :string
#  dsa_id              :string
#  rhsa_id             :string
#  cesa_id             :string
#  source              :string
#  reported_at         :datetime
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

  factory :vulnerable_dependency do
    package_name
    package_platform
    patched_versions { [] }
  end

  factory :vulnerability do
    package_names { [generate(:package_name)] }
    package_platform { FactoryHelper.rand_platform }
    # cve_id { generate(:cve_id) }
    # after(:create) do |v, f|
    #   v.package_names.each do |pname|
    #   create(:vulnerable_dependency, v.package_names.count vulnerability_id: v.id, 
    # end

    factory :ruby_vulnerability do
      package_platform Platforms::Ruby
    end

  end
end

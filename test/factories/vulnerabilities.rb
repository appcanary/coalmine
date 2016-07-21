# == Schema Information
#
# Table name: vulnerabilities
#
#  id               :integer          not null, primary key
#  package_platform :string           not null
#  title            :string
#  description      :text
#  criticality      :string
#  cve_ids          :string           default("{}"), not null, is an Array
#  osvdb_id         :string
#  usn_id           :string
#  dsa_id           :string
#  rhsa_id          :string
#  cesa_id          :string
#  source           :string
#  reported_at      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
#

require File.join(Rails.root, "test/factories", 'factory_helper')

FactoryGirl.define do

  sequence :cve_id do |n|
    "CVE-9999-%04d" % n
  end

  factory :vulnerable_dependency do
    package_platform { dep.platform }
    package_name { dep.name }
   
    patched_versions { ["> #{dep.version}"] }
    unaffected_versions { [] }

    transient do
      dep { build(:package, :ruby) }
    end
  end

  factory :vulnerability do
    package_platform { deps.first.platform }
    cve_ids { [generate(:cve_id)] }

    transient do
      platform_type { :ruby }
      deps { 2.times.map { build(:package, platform_type) } }
    end

    after(:create) do |v, f|
      f.deps.each do |dep|
        create(:vulnerable_dependency, :dep => dep, :vulnerability => v)
      end
    end

  end
end

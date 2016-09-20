# == Schema Information
#
# Table name: vulnerabilities
#
#  id            :integer          not null, primary key
#  platform      :string           not null
#  title         :string
#  description   :text
#  criticality   :string
#  reference_ids :string           default("{}"), not null, is an Array
#  related       :jsonb            default("[]"), not null
#  osvdb_id      :string
#  usn_id        :string
#  dsa_id        :string
#  rhsa_id       :string
#  cesa_id       :string
#  edited        :boolean          default("false")
#  source        :string
#  reported_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  valid_at      :datetime         not null
#  expired_at    :datetime         default("infinity"), not null
#
# Indexes
#
#  index_vulnerabilities_on_expired_at  (expired_at)
#  index_vulnerabilities_on_platform    (platform)
#  index_vulnerabilities_on_valid_at    (valid_at)
#

require File.join(Rails.root, "test/factories", 'factory_helper')

FactoryGirl.define do

  sequence :cve_id do |n|
    "CVE-9999-%04d" % n
  end

  factory :vulnerable_dependency do
    platform { dep.platform }
    package_name { dep.name }
    release { dep.release }
   
    patched_versions { ["> #{dep.version}"] }
    unaffected_versions { [] }

    transient do
      dep { build(:package, :ruby) }
    end
  end

  factory :vulnerability do
    platform { deps.first.platform }
    reference_ids { [generate(:cve_id)] }

    trait :ruby do
      platform { Platforms::Ruby }
    end

    trait :debian do
      platform { Platforms::Debian }
    end

    trait :ubuntu do
      platform { Platforms::Ubuntu }
    end


    transient do
      platform_type { :ruby }
      deps { 2.times.map { build(:package, platform_type) } }
      pkgs { [] }
    end

    after(:create) do |v, f|
      f.deps.each do |dep|
        create(:vulnerable_dependency, :dep => dep, :vulnerability => v)
      end

      f.pkgs.each do |pkg|
        vd = create(:vulnerable_dependency, :dep => pkg, :vulnerability => v)
        create(:vulnerable_package, :dep => pkg, :vulnerable_dependency => vd, :vulnerability => v)
      end
    end

  end
end

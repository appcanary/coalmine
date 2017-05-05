# == Schema Information
#
# Table name: vulnerabilities
#
#  id            :integer          not null, primary key
#  platform      :string           not null
#  title         :string           not null
#  description   :text
#  criticality   :integer          default("0"), not null
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
#  package_names :string           default("{}"), not null, is an Array
#
# Indexes
#
#  index_vulnerabilities_on_criticality_and_reported_at  (criticality,reported_at)
#  index_vulnerabilities_on_expired_at                   (expired_at)
#  index_vulnerabilities_on_platform                     (platform)
#  index_vulnerabilities_on_valid_at                     (valid_at)
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
    affected_versions { [] }

    transient do
      dep { build(:package, :ruby) }
    end

    trait :patchless do
      patched_versions { [] }
    end
  end

  factory :vulnerability do
    platform { Platforms::Ruby }
    reference_ids { [generate(:cve_id)] }
    reported_at { 7.days.ago }

    title { Faker::Lorem.sentence }

    trait :ruby do
      platform { Platforms::Ruby }
    end

    trait :debian do
      platform { Platforms::Debian }
    end

    trait :ubuntu do
      platform { Platforms::Ubuntu }
    end

    trait :amzn do
      platform { Platforms::Amazon }
    end

    trait :alpine do
      platform { Platforms::Alpine }
    end

    trait :php do
      platform { Platforms::PHP }
    end

    transient do
      platform_type { platform.to_sym }
      deps { 2.times.map { build(:package, platform_type) } }
      pkgs { [] }
      vd_trait { nil }
    end

    trait :patchless do
      transient do
        vd_trait { :patchless }
      end
    end

    after(:create) do |v, f|
      adv = create(:advisory, :ruby)
      v.advisory_ids = adv.id
      f.deps.each do |dep|
        create(:vulnerable_dependency, f.vd_trait, :dep => dep, :vulnerability => v)
      end

      f.pkgs.each do |pkg|
        vd = create(:vulnerable_dependency, f.vd_trait, :dep => pkg, :vulnerability => v)
        create(:vulnerable_package, :dep => pkg, :vulnerable_dependency => vd, :vulnerability => v)
      end
    end

  end
end

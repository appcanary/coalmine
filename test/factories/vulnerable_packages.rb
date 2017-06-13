# == Schema Information
#
# Table name: vulnerable_packages
#
#  id                       :integer          not null, primary key
#  package_id               :integer          not null
#  vulnerable_dependency_id :integer          not null
#  vulnerability_id         :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  valid_at                 :datetime         not null
#  expired_at               :datetime         default("infinity"), not null
#
# Indexes
#
#  index_vulnerable_packages_on_expired_at                (expired_at)
#  index_vulnerable_packages_on_package_id                (package_id)
#  index_vulnerable_packages_on_valid_at                  (valid_at)
#  index_vulnerable_packages_on_vulnerability_id          (vulnerability_id)
#  index_vulnerable_packages_on_vulnerable_dependency_id  (vulnerable_dependency_id)
#  index_vulnpackage_packages                             (package_id,vulnerable_dependency_id,vulnerability_id) UNIQUE
#

FactoryGirl.define do
  factory :vulnerable_package do
    transient do
      platform_type { :ruby }
      dep { build(:package, platform_type) }
    end
    # pkg_name = Faker::Hacker.ingverb
    package { dep }
  end
end

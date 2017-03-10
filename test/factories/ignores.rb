# == Schema Information
#
# Table name: ignores
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  bundle_id   :integer
#  package_id  :integer          not null
#  criticality :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_ignores_on_account_id                               (account_id)
#  index_ignores_on_account_id_and_bundle_id_and_package_id  (account_id,bundle_id,package_id) UNIQUE
#  index_ignores_on_bundle_id                                (bundle_id)
#  index_ignores_on_package_id                               (package_id)
#

FactoryGirl.define do
  factory :ignore do
    account nil
    bundle nil
    package nil
    criticality 1
  end

end

# == Schema Information
#
# Table name: ignored_packages
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  user_id     :integer          not null
#  package_id  :integer          not null
#  bundle_id   :integer
#  criticality :integer
#  note        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  ignored_packages_by_account_package_bundle_ids  (package_id,account_id,bundle_id) UNIQUE
#  index_ignored_packages_on_account_id            (account_id)
#  index_ignored_packages_on_bundle_id             (bundle_id)
#  index_ignored_packages_on_package_id            (package_id)
#  index_ignored_packages_on_user_id               (user_id)
#

FactoryGirl.define do
  factory :ignored_package do
    account nil
    user nil
    package nil
    bundle nil
    criticality 1
    note nil
  end

end

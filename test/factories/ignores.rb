# == Schema Information
#
# Table name: ignores
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
#  index_ignores_on_account_id                               (account_id)
#  index_ignores_on_account_id_and_bundle_id_and_package_id  (account_id,bundle_id,package_id) UNIQUE
#  index_ignores_on_bundle_id                                (bundle_id)
#  index_ignores_on_package_id                               (package_id)
#  index_ignores_on_user_id                                  (user_id)
#

FactoryGirl.define do
  factory :ignore do
    account nil
    user nil
    package nil
    bundle nil
    criticality 1
    note nil
  end

end

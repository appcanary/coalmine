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

class Ignore < ActiveRecord::Base
  belongs_to :account
  belongs_to :bundle
  belongs_to :package

  validates :account, presence: true
  validates :package, presence: true, uniqueness: { scope: [:account, :bundle] }

  scope :filter_query_for, -> (query, account_id) {
    sane_account_id = sanitize(account_id)

    merge_scope = joins(<<-"IGNORES_QUERY").where("ignores.id is null")
      LEFT JOIN ignores ON
        ignores.account_id = #{sane_account_id} AND
        ignores.package_id = packages.id AND
        (ignores.bundle_id = bundled_packages.bundle_id OR ignores.bundle_id is null)
    IGNORES_QUERY

    query.merge(merge_scope)
  }

end

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

class Ignore < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :bundle
  belongs_to :package

  validates :account, presence: true
  validates :user, presence: true
  validates :package, presence: true, uniqueness: { scope: [:account, :bundle] }

  scope :filter_query_for, -> (query, account_id) {
    sanitized_account_id = sanitize(account_id)

    merge_scope = joins("LEFT JOIN ignores ON
                           ignores.account_id = #{sanitized_account_id} AND
                           ignores.package_id = packages.id AND
                           (ignores.bundle_id = bundled_packages.bundle_id OR ignores.bundle_id is null)")
                    .where("ignores.id is null")

    query.merge(merge_scope)
  }

  scope :relevant_ignores_for, -> (bundle) {
    joins(package: [:vulnerable_packages])
      .where("ignores.bundle_id is null or ignores.bundle_id = ?", bundle.id)
  }

  def global?
    self.bundle_id.nil?
  end

  class << self
    def ignore_package(user, pkg, bundle, note)
      note = nil if note.blank?

      self.create(account: user.account,
                  user: user,
                  package: pkg,
                  bundle: bundle,
                  note: note)
    end

    def unignore_package(user, pkg, bundle)
      binding.pry
      self.where(account_id: user.account_id,
                 user_id: user.id,
                 package_id: pkg.id,
                 bundle_id: bundle && bundle.id)
        .take
        .delete
    end
  end
end

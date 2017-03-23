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
#  ignored_packages_by_account_package_bundle_ids  (account_id,package_id,bundle_id) UNIQUE
#  index_ignored_packages_on_account_id            (account_id)
#  index_ignored_packages_on_bundle_id             (bundle_id)
#  index_ignored_packages_on_package_id            (package_id)
#  index_ignored_packages_on_user_id               (user_id)
#

class IgnoredPackage < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :bundle
  belongs_to :package

  has_many :vulnerable_packages, :foreign_key => :package_id, :primary_key => :package_id
  has_many :bundled_packages, :foreign_key => :package_id, :primary_key => :package_id

  validates :account, presence: true
  validates :user, presence: true
  validates :package, presence: true, uniqueness: { scope: [:account, :bundle] }

  scope :filter_query_for, -> (query, account_id) {
    sanitized_account_id = sanitize(account_id)
    primary_key = query.klass.resolution_log_primary_key

    merge_scope = joins("LEFT JOIN ignored_packages ON
                           ignored_packages.account_id = #{sanitized_account_id} AND
                           ignored_packages.package_id = #{primary_key} AND
                           (ignored_packages.bundle_id = bundled_packages.bundle_id OR ignored_packages.bundle_id is null)")
                    .where("ignored_packages.id is null")

    query.merge(merge_scope)
  }

  scope :relevant_ignores_for, -> (bundle) {
    joins(:vulnerable_packages)
      .where("ignored_packages.bundle_id is null or ignored_packages.bundle_id = ?", bundle.id)
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
      self.where(account_id: user.account_id,
                 user_id: user.id,
                 package_id: pkg.id,
                 bundle_id: bundle && bundle.id)
        .take
        .delete
    end
  end
end

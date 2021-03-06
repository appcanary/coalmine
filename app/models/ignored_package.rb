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

  scope :filter_query_for, -> (query, account_id = nil) {
    if account_id
      sanitized_account_id = sanitize(account_id)
    else
      sanitized_account_id = "bundles.account_id"
    end


    primary_key = query.klass.resolution_log_primary_key

    merge_scope = where("NOT EXISTS (SELECT 1 FROM ignored_packages WHERE
                           ignored_packages.account_id = #{sanitized_account_id} AND
                           ignored_packages.package_id = #{primary_key} AND
                           (ignored_packages.bundle_id = bundled_packages.bundle_id OR ignored_packages.bundle_id is null))")

    query.merge(merge_scope)
  }

  scope :relevant_ignores_for, -> (bundle) {
    joins(:vulnerable_packages).
      where("ignored_packages.account_id = ? and (ignored_packages.bundle_id is null or ignored_packages.bundle_id = ?)", bundle.account.id, bundle.id)
  }

  # used ONLY in the form
  attr_accessor :global
  def global?
    self.bundle_id.nil?
  end

  def self.ignore_package(user, pkg, bundle, note)
    if bundle.present? and bundle.account_id != user.account_id
      raise ArgumentError.new("tried to ignore on a bundle (#{bundle.id}) not belonging to user's (#{user.id}) account")
    end
    note = nil if note.blank?

    self.create(account: user.account,
                user: user,
                package: pkg,
                bundle: bundle,
                note: note)
  end

  def self.unignore_package(user, ignored_package_id)
    self.where(account_id: user.account_id,
               user_id: user.id,
               id: ignored_package_id).delete_all
  end
end

# == Schema Information
#
# Table name: bundled_packages_archive
#
#  id                 :integer          not null, primary key
#  bundled_package_id :integer
#  bundle_id          :integer
#  package_id         :integer
#  valid_at           :datetime         not null
#  expired_at         :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# TODO: enforce uniqueness constraint

class BundledPackageArchive < ActiveRecord::Base
  belongs_to :bundled_package
  belongs_to :package
  belongs_to :bundle

  scope :as_of_archive, ->(time) {
    select("bundled_package_id as id, bundle_id, package_id, created_at, updated_at, valid_at, expired_at").where("valid_at <= ? and valid_at >= ?", time, time)
  }

  def self.as_of(time)
    q1 = BundledPackageArchive.as_of_archive(time)

    q2 = BundledPackage.where("valid_at <= ? and expired_at = ?", time, 'Infinity')

    BundledPackage.from("(#{q1.to_sql} UNION #{q2.to_sql}) AS bundled_packages")
  end

  def self.revisions
    # lol subquery allows us to use #count properly
    # if we just select distinct directly, Arel #count
    # will wrap the query in a way that is not valid SQL
    self.from("(select DISTINCT(valid_at, expired_at), valid_at, expired_at from bundled_package_archives) as bundled_package_archives").order(:valid_at)
  end

  def self.prev_revision
    t = revisions.last.valid_at
    BundledPackage.from("(#{self.as_of_archive(t).to_sql}) AS bundled_packages")
  end
end

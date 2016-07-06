# == Schema Information
#
# Table name: bundled_package_archives
#
#  id                 :integer          not null, primary key
#  bundled_package_id :integer          not null
#  bundle_id          :integer          not null
#  package_id         :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  valid_at           :datetime         not null
#  expired_at         :datetime         not null
#

# TODO: enforce uniqueness constraint

class BundledPackageArchive < ActiveRecord::Base
  belongs_to :bundled_package
  belongs_to :package
  belongs_to :bundle

  scope :select_valid_as_of, ->(time) {
    select("bundled_package_id as id, bundle_id, package_id, created_at, updated_at, valid_at, expired_at").where("valid_at <= ? and expired_at > ?", time, time)
  }

  def self.as_of(time)
    q1 = BundledPackageArchive.select_valid_as_of(time)

    q2 = BundledPackage.where("valid_at <= ? and expired_at = ?", time, 'Infinity')

    BundledPackage.from("(#{q1.to_sql} UNION #{q2.to_sql}) AS bundled_packages")
  end

  def self.revisions(bundle_id)
    # lol doing this as a subquery allows us to 
    # use #count properly, given we're selecting distinct
    # columns. If not in a subquery, Arel's #count
    # will wrap the query in a way that is not valid SQL
    # https://github.com/rails/rails/issues/5554
    self.from("(select DISTINCT(valid_at, expired_at), bundle_id, valid_at, expired_at from bundled_package_archives) as bundled_package_archives").where(:bundle_id => bundle_id).order(:valid_at)
  end

  def self.prev_revision(bundle_id)
    t = revisions(bundle_id).last.valid_at
    BundledPackage.from("(#{self.as_of_archive(t).to_sql}) AS bundled_packages").where(:bundle_id => bundle_id)
  end
end

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
# Indexes
#
#  idx_bundled_package_id_ar                     (bundled_package_id)
#  index_bundled_package_archives_on_bundle_id   (bundle_id)
#  index_bundled_package_archives_on_expired_at  (expired_at)
#  index_bundled_package_archives_on_package_id  (package_id)
#  index_bundled_package_archives_on_valid_at    (valid_at)
#

# TODO: enforce uniqueness constraint

class BundledPackageArchive < ActiveRecord::Base
  belongs_to :bundled_package
  belongs_to :package
  belongs_to :bundle

  scope :select_log_joins_vulns, -> {
    select('"bundled_package_archives".bundle_id, 
           "bundled_package_archives".package_id, 
           "bundled_package_archives".bundled_package_id,
           "bundled_package_archives".expired_at occurred_at,
           "vulnerable_packages".id vulnerable_package_id, 
           "vulnerable_packages".vulnerable_dependency_id vulnerable_dependency_id, 
           "vulnerable_packages".vulnerability_id').
           joins('INNER JOIN "vulnerable_packages" ON
            "vulnerable_packages".package_id = "bundled_package_archives".package_id')

  }

  # don't give me vulns that happened AFTER the package stopped
  # being in my system
  scope :select_valid_log_joins_vulns, -> {
    select_log_joins_vulns.where('"vulnerable_packages".valid_at < "bundled_package_archives".expired_at')
  }

  scope :select_valid_as_of, ->(time) {
    select("bundled_package_id as id, bundle_id, package_id, created_at, updated_at, valid_at, expired_at").where("valid_at <= ? and expired_at > ?", time, time)
  }

  def self.as_of(time)
    q1 = BundledPackageArchive.select_valid_as_of(time)

    q2 = BundledPackage.where("valid_at <= ? and expired_at = ?", time, 'Infinity')

    BundledPackage.from("(#{q1.to_sql} UNION #{q2.to_sql}) AS bundled_packages")
  end

  # ---- unused, maybe for future use of revisions
  scope :select_as_bp, -> { 
    select("bundled_package_id as id, bundled_package_archives.bundle_id, bundled_package_archives.package_id, bundled_package_archives.created_at, bundled_package_archives.updated_at, bundled_package_archives.valid_at, bundled_package_archives.expired_at ")
  }


  def self.revisions(bundle_id)
    # lol doing this as a subquery allows us to 
    # use #count properly, given we're selecting distinct
    # columns. If not in a subquery, Arel's #count
    # will wrap the query in a way that is not valid SQL
    # https://github.com/rails/rails/issues/5554
    self.from("(select DISTINCT(valid_at, expired_at), bundle_id, valid_at, expired_at from bundled_package_archives) as bundled_package_archives").where(:bundle_id => bundle_id).order(:valid_at)
  end

=begin
# not used atm, comment ou
  def self.prev_revision(bundle_id)
    # t = revisions(bundle_id).last.valid_at
    # q = select("bundled_package_id as id, bundle_id, package_id, created_at, updated_at, valid_at, expired_at").where("valid_at
    #
    query = select_as_bp.joins("INNER JOIN (#{revisions(bundle_id).to_sql}) as archive ON archive.valid_at = bundled_package_archives.valid_at and archive.expired_at = bundled_package_archives.expired_at").where("bundled_package_archives.valid_at <= archive.valid_at and bundled_package_archives.expired_at > archive.expired_at").where(:bundle_id => bundle_id)

    BundledPackage.from("(#{query.to_sql}) AS bundled_packages")
    # BundledPackage.from("(#{self.select_valid_as_of(t).to_sql}) AS bundled_packages").where(:bundle_id => bundle_id)



    # BundledPackage.from("(#{self.select_valid_as_of(t).to_sql}) AS bundled_packages").where(:bundle_id => bundle_id)
  end
=end
end

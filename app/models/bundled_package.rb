# == Schema Information
#
# Table name: bundled_packages
#
#  id         :integer          not null, primary key
#  bundle_id  :integer          not null
#  package_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  valid_at   :datetime         not null
#  expired_at :datetime         default("infinity"), not null
#
# Indexes
#
#  index_bundled_packages_on_bundle_id   (bundle_id)
#  index_bundled_packages_on_expired_at  (expired_at)
#  index_bundled_packages_on_package_id  (package_id)
#  index_bundled_packages_on_valid_at    (valid_at)
#

# TODO: enforce uniqueness constraint

class BundledPackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :bundle

  has_many :vulnerable_packages, :foreign_key => :package_id, :primary_key => :package_id
  has_many :log_resolutions, :foreign_key => :package_id, :primary_key => :package_id

  scope :affected_by_vuln, -> (account_id, vuln_id) {
    joins("inner join bundles on bundles.id = bundled_packages.bundle_id
           inner join vulnerable_packages vp on vp.package_id = bundled_packages.package_id").where("bundles.account_id = ? and vp.vulnerability_id = ?", account_id, vuln_id).includes(:package, :bundle)

  }

  # selecting the cols needed for LBV and LBP,
  # joined on VP where the package_id matches
  scope :select_log_joins_vulns, -> { 
    select('"bundled_packages".bundle_id, 
           "bundled_packages".id bundled_package_id, 
           "bundled_packages".package_id, 
           "vulnerable_packages".id vulnerable_package_id, 
           "vulnerable_packages".vulnerable_dependency_id, 
           "vulnerable_packages".vulnerability_id,
           "bundled_packages".valid_at occurred_at').
           joins_vulns 
  }

  scope :joins_vulns, -> {
    joins('INNER JOIN "vulnerable_packages" ON
           "vulnerable_packages".package_id = "bundled_packages".package_id')

  }


  scope :where_lbv_not_already_logged, -> {
    where('NOT EXISTS 
           (SELECT 1 FROM "log_bundle_vulnerabilities" lbv 
           WHERE lbv.bundle_id = "bundled_packages".bundle_id AND 
                 lbv.package_id = "bundled_packages".package_id AND 
                 lbv.bundled_package_id = "bundled_packages".id AND 
                 lbv.vulnerability_id = "vulnerable_packages".vulnerability_id AND 
                 lbv.vulnerable_dependency_id = "vulnerable_packages".vulnerable_dependency_id AND 
                 lbv.vulnerable_package_id = "vulnerable_packages".id)')
  }

  scope :revisions, -> (bundle_id) {
    self.from(union(all, BundledPackageArchive.select_as_archived)).select("distinct(valid_at)").where(:bundle_id => bundle_id).order(:valid_at).map(&:valid_at)
  }

  scope :as_of, -> (time_t) {
    from(build_as_of(time_t) )
  }

  def self.union(arel1, arel2)
    "((#{arel1.to_sql}) UNION ALL (#{arel2.to_sql})) bundled_packages"
  end

  def self.build_as_of(time_t)
    union(all.where("valid_at <= ? and expired_at > ?", time_t, time_t),
          BundledPackageArchive.select_as_archived.where("valid_at <= ? and expired_at > ?", time_t, time_t))
  end


end

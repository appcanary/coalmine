# == Schema Information
#
# Table name: log_bundle_patches
#
#  id                       :integer          not null, primary key
#  bundle_id                :integer          not null
#  package_id               :integer          not null
#  bundled_package_id       :integer          not null
#  vulnerability_id         :integer          not null
#  vulnerable_dependency_id :integer          not null
#  vulnerable_package_id    :integer          not null
#  supplementary            :boolean          default("false"), not null
#  occurred_at              :datetime         not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_log_bundle_patches_on_bundle_id                 (bundle_id)
#  index_log_bundle_patches_on_bundled_package_id        (bundled_package_id)
#  index_log_bundle_patches_on_package_id                (package_id)
#  index_log_bundle_patches_on_vulnerability_id          (vulnerability_id)
#  index_log_bundle_patches_on_vulnerable_dependency_id  (vulnerable_dependency_id)
#  index_log_bundle_patches_on_vulnerable_package_id     (vulnerable_package_id)
#  index_of_seven_kings_LBP                              (bundle_id,package_id,bundled_package_id,vulnerability_id,vulnerable_dependency_id,vulnerable_package_id,occurred_at) UNIQUE
#  index_of_six_kings_LBP                                (bundle_id,package_id,bundled_package_id,vulnerability_id,vulnerable_dependency_id,vulnerable_package_id) UNIQUE
#

# Creates historical record of when a bundle has stopped being 
# associated with a vulnerability, and how.
#
# The supplementary flag tracks whether the change was
# initiated by the system (i.e. new or changed vulnerability)
# or by the user (i.e. bundle packages were changed).
class LogBundlePatch < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :package
  belongs_to :bundled_package
  belongs_to :vulnerability
  belongs_to :vulnerable_dependency
  belongs_to :vulnerable_package

  has_many :notifications

  # we want all LBPs that point to:
  # 1. vuln_deps that currently exist (i.e. not since deleted)
  # 2. bundles that currently exist
  # 3. that have NOT already been put into a notification

  scope :unemailed, -> {
    joins(:vulnerable_dependency).
      joins(:bundle).
      where("NOT EXISTS (SELECT NULL FROM notifications WHERE notifications.log_bundle_patch_id = log_bundle_patches.id AND notifications.email_message_id IS NOT NULL)")
  }

  scope :unwebhooked, -> {
    joins(:vulnerable_dependency).
      joins(:bundle).
      joins("INNER JOIN webhooks ON webhooks.account_id = bundles.account_id").
      where("NOT EXISTS (SELECT NULL FROM notifications WHERE notifications.log_bundle_patch_id = log_bundle_patches.id AND notifications.webhook_message_id IS NOT NULL)")
  }

  scope :patchable, -> {
    current_scope.merge(VulnerableDependency.patchable)
  }

  #-----

  scope :select_bundles_and_vulns, -> {
    select("bundles.agent_server_id, log_bundle_patches.bundle_id, log_bundle_patches.package_id, log_bundle_patches.vulnerability_id, log_bundle_patches.supplementary")
  }

   scope :in_bundles_from, -> (account_id) {
    @previously_saved_account_id = sanitize(account_id)
    joins("INNER JOIN 
          (SELECT id, agent_server_id FROM bundles WHERE bundles.account_id = #{@previously_saved_account_id}) bundles ON 
          bundles.id = log_bundle_patches.bundle_id").select("log_bundle_patches.*").select("bundles.agent_server_id")

   }
 
   # TODO: document the importance of bp_id > bp_id
   scope :that_are_not_vulnerable , -> {
     joins("LEFT JOIN log_bundle_vulnerabilities ON 
          log_bundle_vulnerabilities.bundle_id = log_bundle_patches.bundle_id AND
          log_bundle_vulnerabilities.bundled_package_id > log_bundle_patches.bundled_package_id AND
          log_bundle_vulnerabilities.package_id = log_bundle_patches.package_id AND
          log_bundle_vulnerabilities.vulnerability_id = log_bundle_patches.vulnerability_id AND
          log_bundle_vulnerabilities.vulnerable_dependency_id = log_bundle_patches.vulnerable_dependency_id AND
          log_bundle_vulnerabilities.vulnerable_package_id = log_bundle_patches.vulnerable_package_id").
          where('"log_bundle_vulnerabilities".id IS NULL')
   }

   scope :not_vulnerable_as_of, -> (end_at) {
     joins(:vulnerable_dependency).
     joins("LEFT JOIN log_bundle_vulnerabilities ON 
          log_bundle_vulnerabilities.bundle_id = log_bundle_patches.bundle_id AND
          log_bundle_vulnerabilities.bundled_package_id > log_bundle_patches.bundled_package_id AND
          log_bundle_vulnerabilities.package_id = log_bundle_patches.package_id AND
          log_bundle_vulnerabilities.vulnerability_id = log_bundle_patches.vulnerability_id AND
          log_bundle_vulnerabilities.vulnerable_dependency_id = log_bundle_patches.vulnerable_dependency_id AND
          log_bundle_vulnerabilities.vulnerable_package_id = log_bundle_patches.vulnerable_package_id AND
           log_bundle_vulnerabilities.occurred_at <= #{sanitize(end_at)}").
     where('"log_bundle_vulnerabilities".id IS NULL').
     where("vulnerable_dependencies.valid_at <= ?", end_at)
   }

   scope :vulnerable_after, -> (begin_at) {
     joins(:vulnerable_dependency).
     where("vulnerable_dependencies.valid_at >= ?", begin_at)
   }


    scope :patched_between, -> (begin_at, end_at) {
      where("log_bundle_patches.occurred_at >= ? AND log_bundle_patches.occurred_at <= ?", begin_at, end_at)
  }





  
  ##----


  # Every time a bundle is changed, note whether
  # the bundle is *no longer* vulnerable to a vuln
  # at that point in time.
  #
  # We create a log instances whenever:
  # 1. A bundle is updated, and is no longer vuln
  # 2. Vulnerability that affects a package in bundle gets deleted
  # 3. Vulnerability that affects a package is edited, & package no longer affected
  
  def self.record_vulnerability_change!(vuln_id)


    # a vuln has been changed. There are either new
    # packages in bundles affected by it, or there are fewer
    # packages in bundles affected by it.
    #
    # two options: 
    # 1) a vuln change has added vuln packgs
    # 2) a vuln change has removed vuln pkgs
    #
    # this is a patch log so we do not care about 1). 
    # in the event of 2), by definition we'll have removed
    # a VulnerablePackage.
    #
    # So, we need to look inside VulnerablePackageArchive.
    #
    # Will we care about BundledPackageArchive? No, because
    # those packages are in the past - they're "vulnerable" retroactively,
    # but there's no patch notification, kind of pointless info.
    #
    # "You USED to have packages that, turns out, are vulnerable!" -- 
    # not useful information.
    #
    # Therefore, this should only affect thigns in current bundles.
    # Specifically, we're only concerned with packages in current bundles
    # that used to be affected by this vuln but now aren't.
    
    lbp = BundledPackage.
      select('"bundled_packages".bundle_id, 
           "bundled_packages".id bundled_package_id, 
           "bundled_packages".package_id, 
           "vulnerable_package_archives".id vulnerable_package_id, 
           "vulnerable_package_archives".vulnerable_dependency_id,
           "vulnerable_package_archives".vulnerability_id,
           "vulnerable_package_archives".expired_at occurred_at').
           joins('INNER JOIN "vulnerable_package_archives" ON "vulnerable_package_archives".package_id = "bundled_packages".package_id').
           where('"bundled_packages".valid_at < "vulnerable_package_archives".expired_at').
           where('"vulnerable_package_archives".vulnerability_id = ?', vuln_id).
           where('NOT EXISTS
            (SELECT 1 from "log_bundle_patches" lbp WHERE 
            lbp.bundle_id = "bundled_packages".bundle_id AND
            lbp.package_id = "bundled_packages".package_id AND
            lbp.bundled_package_id = "bundled_packages".id AND
            lbp.vulnerability_id = "vulnerable_package_archives".vulnerability_id AND
            lbp.vulnerable_dependency_id = "vulnerable_package_archives".vulnerable_dependency_id AND
            lbp.vulnerable_package_id = "vulnerable_package_archives".id AND
            lbp.occurred_at = "vulnerable_package_archives".expired_at)')


    lbp.each do |lbp|
     self.create(:bundle_id => lbp.bundle_id,
                 :package_id => lbp.package_id,
                 :bundled_package_id => lbp.bundled_package_id,
                 :vulnerability_id => lbp.vulnerability_id,
                 :vulnerable_dependency_id => lbp.vulnerable_dependency_id,
                 :vulnerable_package_id => lbp.vulnerable_package_id,
                 :supplementary => true,
                 :occurred_at => lbp.occurred_at)
    end

  end

  def self.record_bundle_patches!(bundle_id)

    # get a list of ALL BPAs, formatted as an LBP
    # that have ever been vulnerable (i.e. there exists a VulnPkg,
    # that existed while the bundled package was present in a bundle) that
    # are not present in the list of vulnerable packages in the current
    # bundle, that have not already been logged in the LBP.
    lbp = BundledPackageArchive.select_valid_log_joins_vulns.
      where(:bundle_id => bundle_id).
      where("bundled_package_id NOT IN 
            (#{BundledPackage.select("id").joins_vulns.where(:bundle_id => bundle_id).to_sql})").
      where('NOT EXISTS
            (SELECT 1 from "log_bundle_patches" lbp WHERE 
            lbp.bundle_id = "bundled_package_archives".bundle_id AND
            lbp.package_id = "bundled_package_archives".package_id AND
            lbp.bundled_package_id = "bundled_package_archives".bundled_package_id AND
            lbp.vulnerability_id = "vulnerable_packages".vulnerability_id AND
            lbp.vulnerable_dependency_id = "vulnerable_packages".vulnerable_dependency_id AND
            lbp.vulnerable_package_id = "vulnerable_packages".id AND
            lbp.occurred_at = "bundled_package_archives".expired_at)')


    lbp.each do |lbp|
     self.create(:bundle_id => lbp.bundle_id,
                 :package_id => lbp.package_id,
                 :bundled_package_id => lbp.bundled_package_id,
                 :vulnerability_id => lbp.vulnerability_id,
                 :vulnerable_dependency_id => lbp.vulnerable_dependency_id,
                 :vulnerable_package_id => lbp.vulnerable_package_id,
                 :occurred_at => lbp.occurred_at)
    end
  end

  def self.resolution_log_primary_key
    "log_bundle_patches.package_id"
  end
end

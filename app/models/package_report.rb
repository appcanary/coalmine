class PackageReport < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :package
  belongs_to :vulnerable_dependency
  belongs_to :vulnerability

  scope :from_patched_notifications, ->(notifications) {
    inner_q = LogBundlePatch.where("id in (#{notifications.select("log_bundle_patch_id").to_sql})")

    from_as(inner_q).includes(:package, :vulnerable_dependency, :vulnerability)
  }

   scope :from_vuln_notifications, ->(notifications) {
    inner_q = LogBundleVulnerability.where("id in (#{notifications.select("log_bundle_vulnerability_id").to_sql})")

    from_as(inner_q).includes(:package, :vulnerable_dependency, :vulnerability)
  }

   scope :from_bundle, -> (bundle) {
     inner_q = bundle.vulnerable_packages.distinct_package.select("bundled_packages.bundle_id")

     from_as(inner_q).includes(:package, :vulnerable_dependency, :vulnerability, :bundle)
   }

   # TODO: has this been tested? hrm.
   scope :from_packages, -> (package_query) {
     inner_q = package_query.joins(:vulnerable_packages).select("packages.id package_id, packages.name, packages.version, vulnerable_packages.id vulnerable_package_id, vulnerable_packages.vulnerability_id, vulnerable_packages.vulnerable_dependency_id")
     from_as(inner_q).includes(:package, :vulnerable_dependency, :vulnerability)
   }

   scope :from_as, -> (q) {
     from("(#{q.to_sql}) AS package_reports")
   }


   delegate :name, :version, :platform, :vulnerabilities, :vulnerable_dependencies, :to => :package


   #----- handle tableless ActiveRecord

   def self.columns
     @columns ||= LogBundleVulnerability.columns
   end

   # to be able to add new columns
   def self.column(name, sql_type = nil, default = nil, null = true)
     @columns ||= [];
     @columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
                                                              sql_type.to_s, null)
   end

   # Override the save method to prevent exceptions.
   def save(validate = true)
     validate ? valid? : true
   end
end

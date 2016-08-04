class PackageReport < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :package
  belongs_to :vulnerable_dependency
  belongs_to :vulnerability

  scope :from_patched_notifications, ->(notifications) {
    inner_q = LogBundlePatch.where("id in (#{notifications.select("log_bundle_patch_id").to_sql})")

    from("(#{inner_q.to_sql}) AS package_reports").includes(:package, :vulnerable_dependency, :vulnerability)
  }

   scope :from_vuln_notifications, ->(notifications) {
    inner_q = LogBundleVulnerability.where("id in (#{notifications.select("log_bundle_vulnerability_id").to_sql})")

    from("(#{inner_q.to_sql}) AS package_reports").includes(:package, :vulnerable_dependency, :vulnerability)
  }

   scope :from_bundle, -> (bundle) {
     inner_q = bundle.vulnerable_packages.distinct_package

     from("(#{inner_q.to_sql}) AS package_reports").includes(:package, :vulnerable_dependency)
   }

   scope :from_packages, -> (package_query) {
     from("(#{package_query.to_sql}) AS package_reports").includes(:package, :vulnerable_dependency)
   }



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

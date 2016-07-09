class Checker
  attr_accessor :account, :platform, :release

  def initialize(account, environ)
    self.account = account
    self.platform = environ[:platform]
    self.release = environ[:release]
  end

  def check(package_list)
    packages = PackageManager.new(platform, release).find_or_create(package_list)

    # replace with intermediate model?
    LogBundleVulnerability.from("(#{Package.fetch_vulnerabilities(packages).to_sql}) as log_bundle_vulnerabilities")
  end
end

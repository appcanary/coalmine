class PackageManager
  attr_accessor :platform, :release

  # TODO: incorporate versions

  def initialize(platform, release)
    @platform = platform
    @release = release
  end

  # TODO wrap in txn?
  # TODO handle errors sanely
  def find_or_create(package_list)
    existing_packages = find_existing_packages(package_list)

    # we might not know about every package submitted.
    # Let's check!

    new_packages = create_missing_packages(existing_packages, package_list)

    existing_packages + new_packages
  end

  def create_missing_packages(existing_packages, package_list)
    # if these two lists are the same size, our job here is done
    if existing_packages.count == package_list.count
      return []
    end
    
    existing_set = existing_packages.select("name, version").pluck(:name, :version).to_set

    submitted_set = package_list.map { |p| [p[:name], p[:version]]}.to_set

    new_packages = submitted_set - existing_set

    new_packages.map do |name, version|
      self.create(:name => name,
                 :version => version)
    end
  end

  def find_existing_packages(package_list)
    # TODO: make sure this queries names AND versions
    query = Package.where(:platform => @platform,
                          :release => @release)
    clauses = []
    values = []
    package_list.each do |pkg|
      clauses << "(name = ? AND version = ?)"
      values << pkg[:name]
      values << pkg[:version][:number]
    end

    query.where(clauses.join(" OR "), *values)
  end

  # whenever we create a package, we check to see if it's vuln
  def create(pkg)
    package = Package.new(:platform => @platform,
                       :release => @release,
                       :name => pkg[:name],
                       :version => pkg[:version],
                       :origin => "user")

    unless package.save
      raise "package problem, deal with this somehow later"
    end

    possible_vulns = package.concerning_vulnerabilities
    VulnerabilityManager.new.update_affecting_vulnerabilities!(possible_vulns, package)
    return package
  end
end

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
    if existing_packages.size == package_list.size
      return []
    end

    # TODO: calculate which package(name, version) we haven't seen yet
    # put it into new_packages

    new_packages.map do |pkg|
      self.create(pkg)
    end
  end

  def find_existing_packages(package_list)
    # TODO: make sure this queries names AND versions
    Package.where(:platform => @platform,
                  :release => @release).
                  where("name in (?)", package_names)
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

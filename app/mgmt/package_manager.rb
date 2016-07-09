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
    existing_pkg_query = find_existing_packages(package_list)

    # we might not know about every package submitted.
    # Let's check!

    create_missing_packages(existing_pkg_query, package_list)

    # this is an ActiveRecord_Relation; it gets
    # lazily evaluated from the database.
    # by the time we get here, the missing packages
    # have been added, so when this gets evaluated
    # the query behind it should return all relevant packages
    # thereby negating the need to add new_packages above
    # to this list.
    existing_pkg_query
  end

  # given an Arel query and a list of packages, determines
  # which packages we have not seen yet and creates them.
  #
  # assumes that existing_packages_query was built from
  # the items in package_list.

  def create_missing_packages(existing_packages_query, package_list)
    # if these two lists are the same size, our job here is done
    if existing_packages_query.count == package_list.count
      return []
    end
    
    existing_set = existing_packages_query.select("name, version").pluck(:name, :version).to_set

    submitted_set = package_list.map { |p| [p[:name], p[:version]]}.to_set

    new_packages = submitted_set - existing_set

    new_packages.map do |name, version|
      self.create(:name => name,
                  :version => version)
    end
  end

  def find_existing_packages(package_list)
    return [] if package_list.empty?

    query = Package.where(:platform => @platform,
                          :release => @release)
    clauses = []
    values = []
    package_list.each do |pkg|
      clauses << "(name = ? AND version = ?)"
      values << pkg[:name]
      values << pkg[:version]
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

    package.transaction(requires_new: true) do
      unless package.save
        raise "package problem, deal with this somehow later"
      end

      possible_vulns = package.concerning_vulnerabilities
      VulnerabilityManager.new.update_affecting_vulnerabilities!(possible_vulns, package)
    end
    return package
  end
end

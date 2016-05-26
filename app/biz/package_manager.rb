class PackageManager
  attr_accessor :platform, :release

  # TODO: incorporate versions

  def initialize(platform, release)
    @platform = platform
    @release = release
  end

  # TODO needs to highlight that it creates packages
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

    # when i create a new package, when do I check to see if its vulnerable?
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

  def create(pkg)
    p = Package.create(:platform => @platform,
                       :release => @release,
                       :name => pkg[:name],
                       :version => pkg[:version],
                       :origin => "user")

    possible_vulns = Vulnerability.where(:package_name => pkg[:name],
                                         :package_platform => @platform)

    # insert calc here
    if is_vuln(p, vuln)
      vuln.packages << p
    end

  end
end

# TODO
# handle arch and epoch
# instead of hash should have version values object
# maybe optimize query
class PackageMaker < ServiceMaker
  attr_accessor :platform, :release

  def initialize(platform, release)
    @platform = platform
    @release = release
  end

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
      return Package.none
    end
    
    # TODO: it'd be nice to save the filenames on centos pkgs n'est pas?
    existing_set = existing_packages_query.pluck_relevant_unique_fields(@platform).to_set

    submitted_set = package_list.map(&:to_relevant_values).to_set

    new_packages = submitted_set - existing_set

    fields = Package.relevant_columns(@platform)
    new_packages.map do |pkg|
      # rebuild an attributes hash from set
      hsh = fields.each_with_index.reduce({}) do |h, (k, i)|
        h[k] = pkg[i]
        h
      end
      self.create(hsh)
    end
  end

  def find_existing_packages(package_list)
    return Package.none if package_list.empty?

    query = Package.where(:platform => @platform,
                          :release => @release)
    clauses = []
    values = []
    clause_str = "(#{Package.to_relevant_clauses(@platform)})"

    package_list.each do |pkg|
      clauses << clause_str
      pkg.to_relevant_values.each do |val|
        values << val
      end
    end

    query.where(clauses.join(" OR "), *values)
  end

  # whenever we create a package, we check to see if it's vuln
  def create(hsh)
    package = Package.new(hsh.merge(:platform => @platform,
                                    :release => @release,
                                    :origin=>"user"))

    # current assumption: if there's something wrong with a package, 
    # abort whole txn
    package.save!

    possible_vulns = package.concerning_vulnerabilities
    add_package_to_affecting_vulnerabilities!(possible_vulns, package)
    return package
  end


  # gets called only when new packages are created.

  # this doesn't have to trigger a report because:
  # a report will be triggered when the package gets
  # assigned to a bundle. 
  #
  # there should not be a scenario where this method
  # gets called, on packages that are in a bundle
  # without triggering the bundle update report
  def add_package_to_affecting_vulnerabilities!(possible_vulns, package)
    possible_vulns.select do |vuln|
      if vuln.affects?(package)
        VulnerablePackage.create!(:vulnerability_id => vuln.vulnerability_id,
                                  :package_id => package.id)
      end
    end
  end
end

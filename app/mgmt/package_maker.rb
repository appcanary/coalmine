# TODO
# handle arch and epoch
# maybe optimize query
class PackageMaker < ServiceMaker
  attr_accessor :platform, :release

  def initialize(platform, release, origin = "user", update_all = false)
    @platform = platform
    @release = release
    @origin = origin
    @update_all = update_all
  end

  def find_or_create(package_list)
    existing_packages_query = find_existing_packages(package_list)

    # we might not know about every package submitted.
    # Let's check!

    existing_set = existing_packages_query.pluck_unique_fields
    new_packages = diff_packages(existing_set, package_list)

    new_packages.map do |pkg|
      self.create(pkg.attributes)
    end

    if @update_all
      existing_packages = package_list - new_packages
      update_packages(existing_packages)
    end

    # this is an ActiveRecord_Relation; it gets
    # lazily evaluated from the database.
    # by the time we get here, the missing packages
    # have been added, so when this gets evaluated
    # the query behind it should return all relevant packages
    # thereby negating the need to add new_packages above
    # to this list.
    existing_packages_query
  end

  def find_existing_packages(package_list)
    return Package.none if package_list.empty?

    query = Package.where(:platform => @platform,
                          :release => @release)

    # TODO: what about packages with diff arches?
    query.search_unique_fields(package_list.map(&:unique_values))
  end

  # whenever we create a package, we check to see if it's vuln
  def create(hsh)
    package = Package.new(hsh.merge(:platform => @platform,
                                    :release => @release,
                                    :origin => @origin))

    # current assumption: if there's something wrong with a package, 
    # abort whole txn
    package.save!

    update_vulns(package)
    return package
  end

  def update_packages(package_list)
    package_list.each do |parcel|
      next if parcel.try(:source_name).nil?

      pkgs = Package.where(:platform => @platform, 
                           :release => @release, 
                           :origin => "user").
        where(parcel.unique_hash)

      # we have a problem with dupes but rn that's not my job to fix
      pkgs.each do |pkg|

        h = parcel.attributes.merge(:platform => @platform, 
                                    :release => @release, 
                                    :origin => @origin)
        pkg.assign_attributes(h)

        if pkg.changed? && pkg.save!
          update_vulns(pkg)
        end
      end
    end
  end

  def update_vulns(package)
    possible_vulns = package.concerning_vulnerabilities
    add_package_to_affecting_vulnerabilities!(possible_vulns, package)
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
    possible_vulns.select do |vuln_dep|
      if vuln_dep.affects?(package)
        VulnerablePackage.find_or_create_by!(:vulnerability_id => vuln_dep.vulnerability_id,
                                             :vulnerable_dependency_id => vuln_dep.id,
                                             :package_id => package.id)
      end
    end
  end

  # return items in submitted that are NOT
  # in existing. Assumes existing is an array
  # of arrays and submitted are 'Parcel's
  def diff_packages(existing, submitted)
    existing_set = existing.reduce({}) { |h, k|
      h[k] = true
      h
    }

    submitted_set = {}
    submitted.select { |k|
      # not strictly necc but gets rid of dupes
      if submitted_set[k.unique_values]
        false
      else
        submitted_set[k.unique_values] = true
        existing_set[k.unique_values].nil?
      end
    }
  end
end

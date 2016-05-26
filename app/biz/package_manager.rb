class PackageManager
  attr_accessor :kind, :release

  # TODO: incorporate versions

  def initialize(kind, release)
    @kind = kind
    @release = release
  end

  # TODO needs to highlight that it creates packages
  def parse_list!(package_list)
    package_names = package_list.map { |pl| pl[:name] }
    existing_packages = Package.where(:kind => @kind,
                                      :release => @release).
                                      where("name in (?)", package_names)


    # we might not know about every package submitted.
    # Let's check!

    new_packages = []

    if existing_packages.size < package_names.size
      new_packages = create_missing_packages(existing_packages, package_list)
    end

    existing_packages + new_packages
  end

  def create_missing_packages(existing_packages, package_list)
    existing_names = existing_packages.map(&:name).sort.uniq
    new_packages = package_list.reject do |pl|
      existing_names.any? { |en| en == pl.name }
    end


    # when i create a new package, when do I check to see if its vulnerable?
    new_packages.map do |pkg|
                             
      p = Package.create(:kind => @kind,
                         :release => @release,
                         :name => pkg[:name],
                         :version => pkg[:version],
                         :origin => "user")

      possible_vulns = Vulnerability.where(:package_name => pkg[:name],
                                           :package_kind => @kind)

      # insert calc here
      if is_vuln(p, vuln)
        vuln.packages << p
      end
    end
  end
end

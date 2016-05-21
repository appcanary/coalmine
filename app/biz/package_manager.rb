class PackageManager
  def self.parse_list(kind, release, package_list)
    package_names = package_list.map { |pl| pl[:name] }
    existing_packages = Package.where(:kind => kind,
                                      :release => release).
                                      where("name in (?)", package_names)


    new_packages = create_missing_packages(existing_packages, package_list)

    existing_packages + new_packages
  end

  def self.create_missing_packages(existing_packages, package_list)
    existing_names = existing_packages.map(&:name).sort.uniq
    new_packages = package_list.reject do |pl|
      existing_names.any? { |en| en == pl.name }
    end

    new_packages.map do |name|
      Package.create(:kind => kind,
                     :release => release,
                     :name => name,
                     :origin => "user")
    end
  end
end

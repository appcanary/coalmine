class AlpineAdapter < AdvisoryAdapter.new(:distroversion,
                                          :reponame,
                                          :package_name,
                                          :package_version,
                                          :cve_list)

  def identifier
    "#{distroversion}/#{reponame}/#{package_name}-#{package_version}"
  end

  def source
    AlpineImporter::SOURCE
  end

  def platform
    AlpineImporter::PLATFORM
  end

  generate :package_names do
    [package_name]
  end

  generate :reference_ids do
    cve_list
  end

  generate :title do
    identifier
  end

  generate :patched do
    [{"package_name" => package_name, "version" => package_version}]
  end

  generate :constraints do
    hsh = {
      "package_name" => package_name,
      "patched_versions" => [package_version]
    }

    [DependencyConstraint.parse(hsh)]
  end
end

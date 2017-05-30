class PythonAdapter < AdvisoryAdapter.new(:advisory, :cve, :id, :specs, :v, :package_name)
  def identifier
    id
  end

  def source
    PythonSafetyDbImporter::SOURCE
  end

  def platform
    PythonSafetyDbImporter::PLATFORM
  end

  generate :reference_ids do
    if cve.present?
      [cve]
    else
      []
    end
  end

  generate :title do
    id
  end

  generate :description do
    advisory
  end

  generate :package_names do
    [package_name]
  end

  generate :title do
    identifier
  end

  generate :constraints do
    hsh = {
      "package_name" => package_name,
      "affected_versions" => specs
    }
    
    [DependencyConstraint.parse(hsh)]
  end

  generate :affected do
    specs.map do |raw_constraint|
      {"package_name" => package_name, "version" => raw_constraint}
    end
  end
end

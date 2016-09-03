class AlasAdvisory < AdvisoryPresenter.new(:alas_id, :cve_ids, :severity, 
                                           :released_at, :description, :affected_packages, 
                                           :new_packages)

  def identifier
    alas_id
  end

  def package_platform
    Platforms::Amazon
  end

  def source
    AlasImporter::SOURCE
  end

  generate :description do
    description
  end

  generate :cve_ids do
    cve_ids
  end

  generate :reported_at do
    DateTime.parse(released_at).utc
  end

  generate :patched do
    new_packages.map { |p|
      {"filename" => p}
    }
  end

  generate :criticality do
    if severity
      severity.downcase
    else
      "unknown"
    end
  end

end

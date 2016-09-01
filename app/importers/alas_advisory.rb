class AlasAdvisory < AdvisoryPresenter.new(:alas_id, :cve_ids, :severity, 
                                           :released_at, :description, :affected_packages, 
                                           :new_packages)

  def identifier
    alas_id
  end

  def generate_reported_at
    DateTime.parse(released_at).utc
  end

  def patched
    new_packages.map { |p|
      {"filename" => p}
    }
  end

  def generate_criticality
    if severity
      severity.downcase
    else
      "unknown"
    end
  end

  def package_platform
    Platforms::Amazon
  end

  def source
    AlasImporter::SOURCE
  end

  def advisory_keys
    ["identifier", "package_platform", "reported_at", "criticality", "cve_ids", "description", "patched", "source"]
  end
end

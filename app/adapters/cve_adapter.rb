class CveAdapter < AdvisoryAdapter.new(:cve, :vulnerable_configurations, :cvss, :vulnerable_software, :published_datetime, :last_modified_datetime, :cwe, :summary, :references)

  # TODO: include vulnerable_software, published_datetime, last_modified_datetime
  def identifier
    cve
  end

  def source
    CveImporter::SOURCE
  end

  def platform
    CveImporter::PLATFORM
  end

  generate :reference_ids do
    [cve]
  end

  generate :title do
    cve
  end

  generate :reported_at do
    published_datetime.to_datetime.utc
  end

  generate :description do
    summary
  end

  generate :criticality do
    score = cvss.present? ? cvss[:score] : nil
    case score
    when 0.0..3.3
      "low"
    when 3.3..6.6
      "medium"
    when 6.6..10.0
      "high"
    else
      "unknown"
    end
  end

  generate :source_status do
    cvss
  end

  generate :related do
    [cwe]
  end
end

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
    [cve, cwe]
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

  generate :cvss do
    cvss && cvss[:score]
  end

  generate :criticality do
    cvss_score = cvss && cvss[:score].to_f
    Advisory.cvss_to_criticality(cvss_score)
  end

  generate :source_status do
    cvss.to_json
  end

  generate :related do
    references.map {|x| x[:link]}
  end
end

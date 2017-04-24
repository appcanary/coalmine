class RHSAAdapter < AdvisoryAdapter.new(:rhsa_id, :cves, :title, :severity, :released_on, :description, :references, :source_text)
  def identifier
    rhsa_id
  end

  def source
    RHSAImporter::SOURCE
  end

  def platform
    RHSAImporter::PLATFORM
  end

  generate :reference_ids do
    [rhsa_id].concat(cves)
  end

  generate :title do
    title
  end

  generate :reported_at do
    released_on.to_datetime.utc
  end

  generate :description do
    description
  end

  generate :rhsa_id do
    rhsa_id
  end

  generate :criticality do
    case severity
    when /low/i
      Advisory.criticalities["low"]
    when /moderate/i
      Advisory.criticalities["medium"]
    when /important/i
      Advisory.criticalities["high"]
    when /critical/i
      Advisory.criticalities["critical"]
    else
      Advisory.criticalities["unknown"]
    end
  end

  generate :related do
    references
  end
end

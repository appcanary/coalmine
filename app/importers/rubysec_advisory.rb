# TODO: what about related and url?
class RubysecAdvisory < AdvisoryPresenter.new(:filepath, :gem, :cve, 
                                              :osvdb, :url, :title, 
                                              :date, :description, :cvss_v2, 
                                              :cvss_v3, :patched_versions, :unaffected_versions, 
                                              :related)
  def identifier
    filepath.split("/")[-2..-1].join("/")
  end

  def source
    RubysecImporter::SOURCE
  end

  def package_platform
    Platforms::Ruby
  end


  def to_constraint(c, n)
    {"constraint" => c, "name" => n}
  end

  generate :patched do
    if patched_versions
      patched_versions.map do |pv|
        to_constraint(pv, gem)
      end
    else
      []
    end
  end

  generate :unaffected do
    if unaffected_versions
      unaffected_versions.map do |uv|
        to_constraint(uv, gem)
      end
    else
      []
    end
  end

  generate :reported_at do
    # avoid timezone issues
    DateTime.parse date.iso8601
  end

  def cvss_score
    cvss_v2 || cvss_v3
  end

  generate :criticality do
    case cvss_score
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

  generate :cve_ids do
    if cve
      ["CVE-#{cve}"]
    else
      []
    end
  end

  generate :osvdb_id do
    if osvdb
      "OSVDB-#{osvdb}"
    else
      nil
    end
  end

 
  generate :package_names do
    [gem]
  end

  generate :title do
    title
  end

  generate :description do
    description
  end
end

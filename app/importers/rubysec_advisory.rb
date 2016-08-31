# TODO: what about related and url?
class RubysecAdvisory < Advisory.new(:filepath, :gem, :cve, 
                                     :osvdb, :url, :title, 
                                     :date, :description, :cvss_v2, 
                                     :cvss_v3, :patched_versions, :unaffected_versions, 
                                     :related)
  def identifier
    filepath.split("/")[-2..-1].join("/")
  end

  def to_constraint(c, n)
    {"constraint" => c, "name" => n}
  end

  def generate_patched
    if patched_versions
      patched_versions.map do |pv|
        to_constraint(pv, gem)
      end
    else
      []
    end
  end

  def generate_unaffected
    if unaffected_versions
      unaffected_versions.map do |uv|
        to_constraint(uv, gem)
      end
    else
      []
    end
  end

  def generate_reported_at
    # avoid timezone issues
    DateTime.parse date.iso8601
  end

  def cvss_score
    cvss_v2 || cvss_v3
  end

  def generate_criticality
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

  def generate_cve_ids
    if cve
      ["CVE-#{cve}"]
    else
      []
    end
  end

  def generate_osvdb_id
    if osvdb
      "OSVDB-#{osvdb}"
    else
      nil
    end
  end

  def source
    RubysecImporter::SOURCE
  end

  def package_platform
    Platforms::Ruby
  end

  def package_names
    [gem]
  end

  def advisory_keys
    ["identifier", "package_platform", "package_names", "patched", "unaffected", "title", "description", "cve_ids", "osvdb_id", "reported_at", "criticality", "source"]
  end
end

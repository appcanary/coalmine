# TODO: what about related and url?
class RubysecAdvisory < AdvisoryPresenter.new(:filepath, :gem, :cve, 
                                              :osvdb, :url, :title, 
                                              :date, :description, :cvss_v2, 
                                              :cvss_v3, :patched_versions, :unaffected_versions, 
                                              :related)
  def identifier
    "#{cve_or_osvdb}-#{gem}"
  end

  def source
    RubysecImporter::SOURCE
  end

  def package_platform
    Platforms::Ruby
  end

  def cve_or_osvdb
    if cve
      "CVE-#{cve}"
    elsif 
      "OSVDB-#{osvdb}"
    end
  end

  # rubysec advisories are only ever about 1 package
  generate :constraints do
    hsh = {"package_name" => gem }
    if patched_versions.present?
      hsh["patched_versions"] = patched_versions
    else
      hsh["patched_versions"] = []
    end

    if unaffected_versions.present?
      hsh["unaffected_versions"] = unaffected_versions
    else
      hsh["unaffected_versions"] = []
    end

    [hsh]
  end


  def to_constraint(c, n)
    {"package_name" => n, "version" => c}
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

  generate :reference_ids do
    arr = []
    if cve
      arr << "CVE-#{cve}"
    end

    if osvdb
      arr << "OSVDB-#{osvdb}"
    end

    if related
      if related["cve"]
        arr += related["cve"].map { |s| "CVE-#{s}" }
      end
    end
    arr
  end

  
  generate :title do
    title
  end

  generate :description do
    description
  end

  generate :related do
    r = related || {}
    r["url"] ||= []
    r["url"] << url
    r
  end
end

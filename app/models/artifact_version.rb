class ArtifactVersion < ApiBase
  def kind
    platform || self["kind"]
  end

  def is_vulnerable?
    vulnerability.present?
  end

  def vulnerabilities
    if_enum(vulnerability || self["vulnerabilities"]).map do |v|
      Vulnerability.parse(v)
    end
  end
end

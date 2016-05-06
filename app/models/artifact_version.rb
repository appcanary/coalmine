class ArtifactVersion < ApiBase

  # || here is for legacy reasons to do with IsItVuln
  def name
    attributes["name"] || artifact.try(:first).try(:[], "name")
  end

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

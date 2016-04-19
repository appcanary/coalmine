class ArtifactVersion < ApiBase
  def kind
    platform
  end

  def is_vulnerable?
    vulnerability.present?
  end

  def vulnerabilities
    if_enum(vulnerability).map do |v|
      Vulnerability.parse(v)
    end
  end
end

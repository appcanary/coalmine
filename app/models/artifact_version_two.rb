class ArtifactVersionTwo < ApiBase
  def kind
    platform
  end

  def is_vulnerable?
    vulnerability.present?
  end

  def vulnerabilities
    vulnerability.map do |v|
      VulnerabilityTwo.parse(v)
    end
  end
end

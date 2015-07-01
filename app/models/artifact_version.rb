class ArtifactVersion < CanaryBase
  attr_params :id, :number, :platform, :artifact, :vulnerability, :unknown_origin

  # reminder to rename this key upstream
  has_many Vulnerability, "vulnerability"

  # should only have one artifact per AV
  # but api returns an array
  # so in the meantime we hack
  has_many Artifact, "artifact"
  delegate :first, :to => :artifact, :prefix => true
  delegate :name, :to => :artifact_first

  # delegate :title, :description, :cve, :patched_versions, :to => :vulnerability, :prefix => true

  def kind
    platform
  end

end

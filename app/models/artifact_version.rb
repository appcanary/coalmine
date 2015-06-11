class ArtifactVersion < CanaryBase
  attr_params :id, :number, :platform, :artifact, :vulnerability, :unknown_origin

  has_many Artifact, "artifact"
  has_many Vulnerability, "vulnerability"

  delegate :first, :to => :artifact, :prefix => true
  delegate :name, :to => :artifact_first

  # delegate :title, :description, :cve, :patched_versions, :to => :vulnerability, :prefix => true

  def kind
    platform
  end

end

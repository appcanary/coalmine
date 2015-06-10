class Artifact < CanaryBase
  attr_params :id, :number, :platform, :artifact

  def name
    artifact.first.try(:[], "name")
  end
end

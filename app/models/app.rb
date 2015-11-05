class App < CanaryBase
  attr_params :id, :name, :path, :uuid, :artifact_versions, :vulnerable_artifact_versions, :is_vulnerable

  attr_accessor :server

  has_many ArtifactVersion
  has_many ArtifactVersion, "vulnerable_artifact_versions"

  def vulns
    @vulns ||= self.vulnerable_artifact_versions.map(&:vulnerability).flatten
  end

  def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end

  def vulnerable?
    self.is_vulnerable
  end

  def to_param
    uuid
  end

  def display_name
    name.blank? ? path : name
  end

  def short_path
    path_strs = path.split("/")
    path_strs[0..-2].map(&:first).join("/") + "/" + path_strs[-1]
  end
end

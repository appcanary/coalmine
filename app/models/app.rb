class App < CanaryBase
  attr_params :id, :name, :path, :uuid, :artifact_versions, :vulnerable_to

  attr_accessor :server

  has_many ArtifactVersion
  has_many Vulnerability, "vulnerable_to"

  def vulns
    @vulns ||= self.canary.server_app_vulnerabilities(self.server.uuid, self.uuid)
  end

  def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end

  def vulnerable?
    self.vulnerable_to.present?
  end

  def to_param
    uuid
  end

  def short_path
    path_strs = path.split("/")
    path_strs[0..-2].map(&:first).join("/") + "/" + path_strs[-1]
  end
end

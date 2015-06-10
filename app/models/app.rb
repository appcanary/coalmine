class App < CanaryBase
  attr_params :id, :name, :path, :uuid, :artifact_versions, :vulnerable_to

  attr_accessor :server

  def vulns
    @vulns ||= self.canary.server_app_vulnerabilities(self.server.uuid, self.uuid)
  end

  def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end

  def to_param
    uuid
  end

  def vulnerable?
    self.vulnerable_to.present?
  end
end

class Server < CanaryBase
  attr_params :apps, :last_heartbeat_at, :ip, :name, :hostname, :uname, :id, :uuid, :is_vulnerable

  has_many App

  def display_name
    name.blank? ? hostname : name
  end

  def all_apps
    @applications ||= self.canary.server_apps(uuid).map do |a|
      a.server = self;
      a
    end
  end

  def app(id)
    self.canary.server_app(uuid, id).tap do |a|
      a.server = self
    end
  end

  def vulns
    @vulns ||= self.canary.server_vulnerabilities(uuid)
  end

  def avatar
    RubyIdenticon.create_base64(self.hostname || "", :border_size => 10)
  end

  def gone_silent?
    last_heartbeat_at < 2.hours.ago.iso8601
  end

  def to_param
    uuid
  end

  def update(params)
    self.canary.update_server(uuid, params)
  end

  def destroy
    self.canary.delete_server(uuid).to_s
  end
end

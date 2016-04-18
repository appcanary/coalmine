class Server < ApiBase
  def self.find(user, id)
    client = CanaryClient.new(user.token)
    resp = client.get("servers/#{id}")

    self.parse(resp.body, client)
  end

  def self.find_all(user)
    client = CanaryClient.new(user.token)
    resp = client.get("servers")
    body = resp.body

    body.map do |s| 
      self.parse(s, client)
    end
  end

  def display_name
    name.blank? ? hostname : name
  end

  def apps
    if_enum(self.attributes["apps"]).map do |a|
      App.parse(a, __client)
    end
  end

  def gone_silent?
    last_heartbeat_at < 2.hours.ago.iso8601
  end

  def update(params)
    __client.put("servers/#{uuid}", params)
  end

  def destroy
    __client.delete("servers/#{uuid}")
  end
end

class Backend
  def self.servers_count
    wrap(canary.get("stats/servers/count"))["count"]
  end

  def self.recent_heartbeats
    wrap(canary.get("stats/servers/count-recent-heartbeats"))["count"]
  end

  def self.without_heartbeats
    canary.get("stats/servers/no-heartbeat")
  end

  def self.vulnerabilities_count
    wrap(canary.get("stats/vulnerabilities/count"))["count"]
  end

  def self.artifacts_count
    wrap(canary.get("stats/artifacts/count"))["count"]
  end

  def self.all_users
    canary.get("users")
  end

  def self.wrap(obj)
    obj || {}
  end

  def self.upload_gemfile(contents)
    resp = canary.post("upload", :contents => Base64.strict_encode64(contents), :kind => "gemfile")

    resp.body.map do |av|
      ArtifactVersion.parse(av)
    end
  end


  def self.canary
    @canary ||= CanaryClient.new
  end
end

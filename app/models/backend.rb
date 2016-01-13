class Backend < CanaryBase

  def self.servers_count
    wrap(canary.stats_servers_count)["count"]
  end

  def self.recent_heartbeats
    wrap(canary.stats_servers_count_recent_heartbeats)["count"]
  end

  def self.without_heartbeats
    canary.stats_servers_without_hearbeats
  end

  def self.vulnerabilities_count
    wrap(canary.stats_vulnerabilities_count)["count"]
  end

  def self.artifacts_count
    wrap(canary.stats_artifacts_count)["count"]
  end

  def self.all_users
    canary.all_users
  end


  def self.wrap(obj)
    obj || {}
  end

  def self.canary
    @canary ||= Canary.new
  end
end

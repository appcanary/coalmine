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

  def self.wrap(obj)
    obj || {}
  end

  def self.canary
    @canary ||= Canary.new
  end
end

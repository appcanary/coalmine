class DestroyInactiveJob < CronJob
  INTERVAL = 1.days
  def run(args)
    log "Destroying inactive servers for users that want it"
    Account.wants_purge_inactive.find_each do |a|
      destroyed_servers = a.agent_servers.inactive.destroy_all
      destroyed_servers.each do |s|
        $analytics.deleted_server(a, s)
      end
    end
  end

end

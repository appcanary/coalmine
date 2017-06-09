class AgentServersPresenter
  attr_reader :servers, :active_servers, :silent_servers, 
    :account, :vulnquery

  def initialize(account, vulnquery)
    @account = account
    @vulnquery = vulnquery

    @servers = @account.agent_servers.includes(:bundles, :tags)
    vuln_hsh = @vulnquery.vuln_hsh(@account.bundles.via_agent)

    if @account.show_processes?
     @servers = @servers.includes(:server_processes)
    end

    # We have to explicitly preload the last_heartbeats here instead of above because .active and .inactive join them
    # See http://blog.arkency.com/2013/12/rails4-preloading/
    @active_servers = @servers.active.preload(:last_heartbeat)
    @silent_servers = @servers.inactive.preload(:last_heartbeat)

    @active_servers = @active_servers.map { |s| ServerPresenter.new(@account, @vulnquery, s, vuln_hsh) }
    @silent_servers = @silent_servers.map { |s| ServerPresenter.new(@account, @vulnquery, s, vuln_hsh) }
  end

  def any?
    active_servers.any? || silent_servers.any?
  end

  def active?
    active_servers.any?
  end

  def silent?
    silent_servers.any?
  end
end

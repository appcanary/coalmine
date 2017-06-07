class AgentServersPresenter
  attr_reader :servers, :active_servers, :silent_servers, 
    :account, :vulnquery

  def initialize(account, vulnquery)
    @account = account
    @vulnquery = vulnquery

    scope = @vulnquery.bundles_with_vulnerable_scope
    #TODO fix the vuln scope here, it's not loaded right
    @servers = @account.agent_servers.include_last_heartbeats.includes(scope).includes(:tags)

    if @account.show_processes?
     @servers = @servers.includes(:server_processes)
    end
    @active_servers = @servers.active
    @silent_servers = @servers - @active_servers

    @active_servers = @active_servers.map { |s| ServerPresenter.new(@account, @vulnquery, s) }
    @silent_servers = @silent_servers.map { |s| ServerPresenter.new(@account, @vulnquery, s) }
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

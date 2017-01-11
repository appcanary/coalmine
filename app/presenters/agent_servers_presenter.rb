class AgentServersPresenter
  attr_reader :servers, :active_servers, :silent_servers, 
    :account, :vulnquery

  def initialize(account, vulnquery)
    @account = account
    @vulnquery = vulnquery

    @servers = @account.agent_servers.includes(:bundles)
    @active_servers = @servers.active
    @silent_servers = @servers - @active_servers


    @active_servers = @active_servers.map { |s| ServerPresenter.new(@vulnquery, s) }
    @silent_servers = @silent_servers.map { |s| ServerPresenter.new(@vulnquery, s) }
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

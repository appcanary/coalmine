class AgentServersPresenter
  attr_reader :servers, :active_servers, :silent_servers, 
    :account, :vulnquery

  delegate :any?, :to => :servers
  def initialize(account, coll = nil)
    @account = account
    @vulnquery = VulnQuery.new(account)

    @servers = coll || @account.agent_servers
    @servers = @servers.map { |s| ServerPresenter.new(@vulnquery, s) }

    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)
  end

  def active?
    active_servers.any?
  end

  def silent?
    silent_servers.any?
  end
end

class ServerPresenter
  attr_reader :server, :vulnquery, :bundles

  delegate :id, :to_param, :gone_silent?, 
    :hostname, :display_name, :ip,
    :uname, :last_heartbeat_at, :to => :server

  def initialize(vulnquery, server)
    @server = server
    @vulnquery = vulnquery


    @bundles = @server.bundles.lazy.map { |b| BundlePresenter.new(vulnquery, b) }
  end

  def vulnerable?
    vulnquery.vuln_server?(server)
  end

  def empty?
    server.bundles.empty?
  end
end

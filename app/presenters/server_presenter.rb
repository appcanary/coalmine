class ServerPresenter
  attr_reader :server, :vulnquery, :bundles

  delegate :id, :to_param, :gone_silent?, 
    :hostname, :display_name, :ip,
    :uname, :distro, :last_heartbeat_at, :to => :server

  def initialize(vulnquery, server)
    @server = server
    @vulnquery = vulnquery


    @bundles = @server.bundles.map { |b| BundlePresenter.new(vulnquery, b) }
  end

  def bundles_sys_sorted
    bundles.sort_by { |b| "#{b.system_bundle? ? 0 : 1}#{b.display_name}" } 
  end

  def vulnerable?
    vulnquery.vuln_server?(server)
  end

  def empty?
    server.bundles.empty?
  end

  def vuln_sort_ordinal
    if self.empty?
      1
    elsif self.vulnerable?
      0
    else
      2
    end
  end
end

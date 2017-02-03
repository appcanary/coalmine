class ServerPresenter
  attr_reader :server, :vulnquery, :bundles, :tags, :processes

  delegate :id, :to_param, :gone_silent?, 
    :hostname, :display_name, :ip,
    :uname, :distro, :last_heartbeat_at, :to => :server

  def initialize(vulnquery, server)
    @server = server
    @vulnquery = vulnquery

    @processes = @server.server_processes.map { |p| ServerProcessPresenter.new(p) }
    @bundles = @server.bundles.map { |b| BundlePresenter.new(vulnquery, b) }
    @tags = @server.tags.pluck(:tag)
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

  def has_outdated_processes?
    outdated_processes.any?
  end

  def outdated_processes
    server.server_processes
      .joins(:server_process_libraries)
      .where(server_process_libraries: { outdated: true })
      .order(:pid)
      .distinct
      .map { |p| ServerProcessPresenter.new(p) }
  end

  def has_processes?
    all_processes.any?
  end

  def all_processes
    server.server_processes
      .joins(:server_process_libraries)
      .order(:pid)
      .distinct
      .map { |p| ServerProcessPresenter.new(p) }
  end
end

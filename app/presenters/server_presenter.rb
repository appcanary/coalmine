class ServerPresenter
  attr_reader :server, :vulnquery, :bundles

  delegate :id, :to_param, :gone_silent?, :distro,
    :hostname, :display_name, :ip,
    :uname, :last_heartbeat_at, :to => :server

  def initialize(vulnquery, server)
    @server = server
    @vulnquery = vulnquery
  end

  def vulnerable?
    bundles.any? { |b| b.vulnerable? }
  end

  def bundles
    @bundles ||= @server.bundles.sort_by { |b| b.system_bundle? ? "\0" : b.display_name }.map { |b| BundlePresenter.new(vulnquery, b) }
  end

  def criticalities_order
    criticality_sums = bundles.map(&:criticalities).inject({}) do |acc, b|
      acc.merge(b){ |key, oldval, newval| oldval + newval }
    end
    BundlePresenter.criticalities_order(criticality_sums)

  end

  def empty?
    server.bundles.empty?
  end
end

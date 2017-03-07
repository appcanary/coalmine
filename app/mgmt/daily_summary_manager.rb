class DailySummaryManager
  attr_accessor :account, :date, :begin_at, :end_at, :motds,
    :vulnquery

  def initialize(account, date)
    @account = account
    @date = date
    @begin_at = @date.beginning_of_day
    @end_at = @date.end_of_day

    @motds = Motd.where("remove_at >= ?", @end_at)
    @vulnquery = VulnQuery.new(@account)

    # ---- we now establish some basic facts

    @new_servers = AgentServer.as_of(@end_at).where(:account_id => account.id).created_on(@begin_at)

    @deleted_servers = AgentServer.as_of(@end_at).where(:account_id => account.id).deleted_on(@begin_at)

    @new_apps = Bundle.as_of(@end_at).where(:account_id => account.id).app_bundles.created_on(@begin_at)

    # ---- and we set up the basic queries
    @log_vuln_query = LogBundleVulnerability.in_bundles_from(account.id).unpatched_as_of(@end_at)

    @log_patch_query = LogBundlePatch.in_bundles_from(account.id).not_vulnerable_as_of(@end_at)

    if !vulnquery.care_about_affected?(account)
      @log_vuln_query = @log_vuln_query.patchable
      @log_patch_query = @log_patch_query.patchable
    end

  end

  def create_presenter
    DailySummaryPresenter.new(@vulnquery, 
                              self.fresh_vulns,
                              self.new_vulns, 
                              self.patched_vulns, 
                              self.changes, 
                              @new_servers, @deleted_servers)
  end

  def fresh_vulns
    fresh_vulns = @log_vuln_query.vulnerable_after(@begin_at)

    @fresh_vulns_ct = fresh_vulns.map(&:vulnerability_id).uniq.size
    @fresh_vuln_pkgs_ct = fresh_vulns.map(&:package_id).uniq.size

    @freshly_affected_servers_ct = fresh_vulns.map(&:agent_server_id).uniq.size

    sorted_vulns = sort_group_log_vulns(fresh_vulns)

    FreshVulnsPresenter.new(@fresh_vulns_ct, @fresh_vuln_pkgs_ct, @freshly_affected_servers_ct, sorted_vulns)
  end

  def new_vulns
    new_vulns = @log_vuln_query.where("log_bundle_vulnerabilities.created_at >= ? and log_bundle_vulnerabilities.created_at <= ?", @begin_at, @end_at).vulnerable_before(@begin_at)

    # make sure we don't report on stuff from brand new
    # or deleted servers

    new_vulns = new_vulns.where.not('bundles.agent_server_id': @new_servers.map(&:id) + @deleted_servers.map(&:id))

    @new_vulns_ct = new_vulns.map(&:vulnerability_id).uniq.size
    @new_vuln_pkgs_ct = new_vulns.map(&:package_id).uniq.size

    @new_affected_servers_ct = new_vulns.map(&:agent_server_id).uniq.size

    new_supplmenetary_vulns = new_vulns.select(&:supplementary)
    @new_supplmenetary_vulns_ct = new_supplmenetary_vulns.map(&:vulnerability_id).uniq.size

    sorted_vulns = sort_group_log_vulns(new_vulns)
    NewVulnsPresenter.new(@new_vulns_ct, @new_vuln_pkgs_ct, @new_affected_servers_ct, @new_supplmenetary_vulns_ct, sorted_vulns)
  end

  def patched_vulns
    net_patches = @log_patch_query.where("log_bundle_patches.occurred_at >= ? and log_bundle_patches.occurred_at <= ?", @begin_at, @end_at)

    # make sure we don't report on stuff from brand new
    # or deleted servers

    net_patches = net_patches.where.not('bundles.agent_server_id':  @new_servers.map(&:id) + @deleted_servers.map(&:id)) 

    @net_patched_vulns_ct = net_patches.map(&:vulnerability_id).uniq.size

    @net_patched_pkgs_ct = net_patches.map(&:package_id).uniq.size

    @patched_servers_ct = net_patches.map(&:agent_server_id).uniq.size

    @net_supplementary_vuln_ct = net_patches.select(&:supplementary).map(&:vulnerability_id).uniq.size

    sorted_vulns = sort_group_log_vulns(net_patches)


    PatchedVulnsPresenter.new(@net_patched_vulns_ct, @net_patched_pkgs_ct, @patched_servers_ct, @net_supplementary_vuln_ct, sorted_vulns)
  end

  def changes
    @changes = BundledPackage.revisions.joins(:bundle).where("bundles.account_id" => account.id).except(:select).select("distinct(bundle_id, bundled_packages.valid_at), bundle_id, agent_server_id, bundled_packages.valid_at").where("bundled_packages.valid_at <= ? and bundled_packages.valid_at >= ?", @end_at, @begin_at)
    @changes = @changes.where.not('bundles.agent_server_id': @new_servers.map(&:id) + @deleted_servers.map(&:id))

    @change_server_ct = @changes.map(&:agent_server_id).uniq.size
    @change_pkg_ct = @changes.map do |ch| BundleQuery.new(ch.bundle, ch.valid_at).bundled_packages.where(:valid_at => ch.valid_at) end.flatten.size

    ChangesPresenter.new(@change_pkg_ct, @change_server_ct)
  end


  def sort_group_log_vulns(query)
    query.group_by(&:vulnerability).
      reduce({}) { |hsh, (vuln, logs)|  
        hsh[vuln] = logs.uniq(&:package_id).map(&:package); 
        hsh

      }.sort_by { |vuln, pkgs| 
        [-vuln.criticality_ordinal, -pkgs.size] 
      }
  end

  class FreshVulnsPresenter
    attr_accessor :vuln_ct, :package_ct, :server_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns
    def initialize(vuln_ct, package_ct, server_ct, sorted_vulns)
      @vuln_ct = vuln_ct
      @package_ct = package_ct
      @server_ct = server_ct
      @sorted_vulns = sorted_vulns
    end
  end

  class NewVulnsPresenter
    attr_accessor :vuln_ct, :package_ct, :server_ct, :supplementary_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns
    def initialize(vuln_ct, package_ct, server_ct, supplementary_ct, sorted_vulns)
      @vuln_ct = vuln_ct
      @package_ct = package_ct
      @server_ct = server_ct
      @supplementary_ct = supplementary_ct
      @sorted_vulns = sorted_vulns
    end

  end

  class PatchedVulnsPresenter
    attr_accessor :vuln_ct, :package_ct, :server_ct, :supplementary_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns

    def initialize(vuln_ct, package_ct, server_ct, supplementary_ct, sorted_vulns)
      @vuln_ct = vuln_ct
      @package_ct = package_ct
      @server_ct = server_ct
      @supplementary_ct = supplementary_ct
      @sorted_vulns = sorted_vulns
    end

    def has_supplementary?
      supplementary_ct > 0
    end
  end


  class ChangesPresenter
    attr_accessor :package_ct, :server_ct

    def initialize(package_ct, server_ct)
      @package_ct = package_ct
      @server_ct = server_ct
    end
  end
end

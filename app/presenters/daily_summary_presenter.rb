class DailySummaryPresenter
  attr_accessor :account, :vulnquery, :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns, :changes, :new_servers, :deleted_servers

  def initialize(query)
    @vulnquery = VulnQuery.new(query.account)
    
    @fresh_vulns = FreshVulnsPresenter.new(query.fresh_vulns)
    @new_vulns = NewVulnsPresenter.new(query.new_vulns)
    @patched_vulns = PatchedVulnsPresenter.new(query.patched_vulns)
    @cantfix_vulns = CantFixVulnsPresenter.new(query.cantfix_vulns)
    @changes = ChangesPresenter.new(query.changes)

    @new_servers = query.new_servers
    @deleted_servers = query.deleted_servers
  end

  module SortVulnsByCritAndPackages
    def sort_group_log_vulns(query)
      query.group_by(&:vulnerability).
        reduce({}) { |hsh, (vuln, logs)|  
        hsh[vuln] = logs.uniq(&:package_id).map(&:package); 
        hsh

      }.sort_by { |vuln, pkgs| 
        [-vuln.criticality_ordinal, -pkgs.size] 
      }
    end
  end

  class FreshVulnsPresenter
    include SortVulnsByCritAndPackages
    attr_accessor :vuln_ct, :package_ct, :server_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns

    def initialize(fresh_vulns)
      @sorted_vulns = sort_group_log_vulns(fresh_vulns)

      @vuln_ct = fresh_vulns.map(&:vulnerability_id).uniq.size
      @package_ct = fresh_vulns.map(&:package_id).uniq.size
      @server_ct = fresh_vulns.map(&:agent_server_id).uniq.size
    end
  end

  class NewVulnsPresenter
    include SortVulnsByCritAndPackages
    attr_accessor :vuln_ct, :package_ct, :server_ct, :supplementary_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns

    def initialize(new_vulns)
      @sorted_vulns = sort_group_log_vulns(new_vulns)

      @vuln_ct = new_vulns.map(&:vulnerability_id).uniq.size
      @package_ct = new_vulns.map(&:package_id).uniq.size

      @server_ct = new_vulns.map(&:agent_server_id).uniq.size

      new_supplmenetary_vulns = new_vulns.select(&:supplementary)
      @supplmenetary_ct = new_supplmenetary_vulns.map(&:vulnerability_id).uniq.size
    end

  end

  class PatchedVulnsPresenter
    include SortVulnsByCritAndPackages
    attr_accessor :vuln_ct, :package_ct, :server_ct, :supplementary_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns

    def initialize(patched_vulns)
      @sorted_vulns = sort_group_log_vulns(patched_vulns)

      @vuln_ct = patched_vulns.map(&:vulnerability_id).uniq.size
      @package_ct = patched_vulns.map(&:package_id).uniq.size
      @server_ct = patched_vulns.map(&:agent_server_id).uniq.size
      @supplementary_ct = patched_vulns.select(&:supplementary).map(&:vulnerability_id).uniq.size
    end

    def has_supplementary?
      supplementary_ct > 0
    end
  end

  class CantFixVulnsPresenter
    include SortVulnsByCritAndPackages
    attr_accessor :vuln_ct, :package_ct, :server_ct, :supplementary_ct, :sorted_vulns

    delegate :each, to: :sorted_vulns

    def initialize(cantfix_vulns)
      @sorted_vulns = sort_group_log_vulns(cantfix_vulns)

      @vuln_ct = cantfix_vulns.map(&:vulnerability_id).uniq.size
      @package_ct = cantfix_vulns.map(&:package_id).uniq.size
      @server_ct = cantfix_vulns.map(&:agent_server_id).uniq.size
      @supplementary_ct = cantfix_vulns.select(&:supplementary).map(&:vulnerability_id).uniq.size
    end

    def has_supplementary?
      supplementary_ct > 0
    end
  end



  class ChangesPresenter
    attr_accessor :package_ct, :server_ct

    def initialize(changes)
      @server_ct = changes.map(&:agent_server_id).uniq.size
      # caveat: this is the one presenter that
      # does make a db call.
      
      # iterate over every prev state of the bundle
      # and count the packages
      @package_ct = changes.map do |ch| 
        BundleQuery.new(ch.bundle, ch.valid_at).
          bundled_packages.where(:valid_at => ch.valid_at) 
      end.flatten.size
    end
  end


  def has_fresh_vulns?
    fresh_vulns.vuln_ct > 0
  end

  def has_new_vulns?
    new_vulns.vuln_ct > 0
  end

  def has_patched_vulns?
    patched_vulns.vuln_ct > 0
  end

  def has_cantfix_vulns?
    cantfix_vulns.vuln_ct > 0
  end

  def has_changes?
    changes.package_ct > 0
  end

  def has_new_servers?
    new_servers.any?
  end

  def has_deleted_servers?
    deleted_servers.any?
  end

  def anything_to_report?
    has_fresh_vulns?   || 
      has_new_vulns?   ||
      has_changes?     ||
      has_new_servers? ||
      has_deleted_servers?
  end

  def has_vulns_to_report?
    has_fresh_vulns? || 
      has_new_vulns? ||
      has_cantfix_vulns?
  end

  def has_changes_to_report?
    has_changes? ||
      has_patched_vulns?
  end

  def has_details_to_show?
    has_fresh_vulns? ||
      has_new_vulns? ||
      has_patched_vulns?
  end

end

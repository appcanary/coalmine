class DailySummaryPresenter
  attr_accessor :date, :account, :vulnquery, :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns, :changes, :server_ct, :inactive_server_ct, :new_servers, :deleted_servers

  def initialize(query)
    @account = query.account
    @vulnquery = VulnQuery.new(query.account)
    @date = query.date

    @fresh_vulns = FreshVulnsPresenter.new(query.fresh_vulns)
    @new_vulns = NewVulnsPresenter.new(query.new_vulns)

    @all_vuln_ct = query.all_vuln_ct

    @patched_vulns = PatchedVulnsPresenter.new(query.patched_vulns)
    @cantfix_vulns = CantFixVulnsPresenter.new(query.cantfix_vulns)
    @changes = ChangesPresenter.new(query.changes)

    @all_servers = query.all_servers
    @new_servers = query.new_servers
    @deleted_servers = query.deleted_servers

    @server_ct = @all_servers.count
    active_server_ct = @all_servers.active_as_of(@date).count
    @inactive_server_ct = @server_ct - active_server_ct
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
    attr_accessor :vuln_ct, :package_ct, :server_ct, :sorted_vulns, :package_ids, :server_ids

    delegate :each, to: :sorted_vulns

    def initialize(fresh_vulns)
      @sorted_vulns = sort_group_log_vulns(fresh_vulns)

      @vuln_ct = fresh_vulns.map(&:vulnerability_id).uniq.size
      @package_ct = fresh_vulns.map(&:package_id).uniq.size
      @server_ct = fresh_vulns.map(&:agent_server_id).uniq.size
      @server_ids = fresh_vulns.map(&:agent_server_id).uniq
      @package_ids = fresh_vulns.map(&:package_id).uniq
    end
  end

  class NewVulnsPresenter
    include SortVulnsByCritAndPackages
    attr_accessor :vuln_ct, :package_ct, :server_ct, :supplementary_ct, :sorted_vulns, :package_ids, :server_ids

    delegate :each, to: :sorted_vulns

    def initialize(new_vulns)
      @sorted_vulns = sort_group_log_vulns(new_vulns)

      @vuln_ct = new_vulns.map(&:vulnerability_id).uniq.size
      @package_ct = new_vulns.map(&:package_id).uniq.size

      @server_ct = new_vulns.map(&:agent_server_id).uniq.size
      @server_ids = new_vulns.map(&:agent_server_id).uniq
      @package_ids = new_vulns.map(&:package_id).uniq

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
    attr_accessor :added_ct, :removed_ct, :upgraded_ct, :server_ct

    def initialize(new_changes)
      @server_ct = new_changes[:server_ct]
      @added_ct = new_changes[:added_ct]
      @removed_ct = new_changes[:removed_ct]
      @upgraded_ct = new_changes[:upgraded_ct]
    end
  end


  def total_vuln_ct
    fresh_vulns.vuln_ct + new_vulns.vuln_ct
  end

  def old_vuln_ct
    @all_vuln_ct - total_vuln_ct
  end

  def total_package_ct
    (fresh_vulns.package_ids + new_vulns.package_ids).uniq.size
  end

  def total_server_ct
    (fresh_vulns.server_ids + new_vulns.server_ids).uniq.size
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
    changes.server_ct > 0
  end

  def has_new_servers?
    new_servers.any?
  end

  def has_deleted_servers?
    deleted_servers.any?
  end

  def anything_to_report?
    has_vulns_or_servers_to_report? || has_changes_to_report?
  end

  def has_vulns_or_servers_to_report?
    has_fresh_vulns?     ||
      has_new_vulns?     ||
      has_cantfix_vulns? ||
      has_new_servers?   ||
      has_deleted_servers?
  end

  def has_patchable_vulns_to_report?
    has_fresh_vulns? ||
      has_new_vulns? 
  end

  def has_vulns_to_report?
    has_patchable_vulns_to_report? ||
      has_cantfix_vulns?
  end

  def has_changes_to_report?
    has_changes? ||
      has_patched_vulns?
  end

  def has_details_to_show?
    has_fresh_vulns?     ||
      has_new_vulns?     ||
      has_cantfix_vulns? ||
      has_patched_vulns?
  end

  def subject
    "Daily Summary for #{date}"
  end

  def recipients
    unless Rails.env.production?
      "hello@appcanary.com"
    else
      if $rollout.active?(:redirect_daily_summary)
        "hello@appcanary.com"
      else
        account.email
      end
    end
  end

end

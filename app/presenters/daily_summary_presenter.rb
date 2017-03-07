class DailySummaryPresenter
  attr_accessor :account, :vulnquery, :fresh_vulns, :new_vulns, :patched_vulns, :changes, :new_servers, :deleted_servers

  def initialize(vulnquery, fresh_vulns, new_vulns, patched_vulns, changes, new_servers, deleted_servers)
    @vulnquery = vulnquery
    @fresh_vulns = fresh_vulns
    @new_vulns = new_vulns
    @patched_vulns = patched_vulns
    @changes = changes
    @new_servers = new_servers
    @deleted_servers = deleted_servers
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
      has_new_vulns?
  end

  def has_changes_to_report?
    has_changes? ||
      has_patched_vulns?
  end

end

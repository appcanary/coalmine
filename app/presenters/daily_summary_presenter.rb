class DailySummaryPresenter
  attr_accessor :date, :account, :vulnquery,
                :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns,
                :changes, :server_ct, :inactive_server_ct, :new_servers, :deleted_servers

  def initialize(query)
    @account = query.account
    @vulnquery = VulnQuery.new(query.account)
    @date = query.date

    @fresh_vulns = VulnCollectionPresenter.new(query.fresh_vulns)
    @new_vulns = VulnCollectionPresenter.new(query.new_vulns)

    @all_vuln_ct = query.all_vuln_ct

    @patched_vulns = VulnCollectionPresenter.new(query.patched_vulns)
    @cantfix_vulns = VulnCollectionPresenter.new(query.cantfix_vulns)
    @changes = ChangesPresenter.new(query.changes)

    @all_servers = query.all_servers
    @new_servers = query.new_servers
    @deleted_servers = query.deleted_servers

    @server_ct = @all_servers.count
    active_server_ct = @all_servers.active_as_of(@date).count
    @inactive_server_ct = @server_ct - active_server_ct
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

  def self.create_collection_has_any_methods(*colls)
    colls.each do |coll_name|
      define_method :"has_#{coll_name}?" do
        coll = self.send(coll_name)
        coll.any?
      end
    end
  end

  create_collection_has_any_methods :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns, :changes, :new_servers, :deleted_servers



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

  class VulnCollectionPresenter
    include SortVulnsByCritAndPackages
    attr_accessor :vuln_ct, :package_ct, :server_ct, :sorted_vulns, :package_ids, :server_ids, :supplementary_ct

    delegate :each, to: :sorted_vulns
    def initialize(coll)
      self.sorted_vulns = sort_group_log_vulns(coll)

      self.vuln_ct = coll.map(&:vulnerability_id).uniq.size
      self.package_ct = coll.map(&:package_id).uniq.size
      self.server_ct = coll.map(&:agent_server_id).uniq.size
      self.server_ids = coll.map(&:agent_server_id).uniq
      self.package_ids = coll.map(&:package_id).uniq
      self.supplementary_ct = coll.select(&:supplementary).map(&:vulnerability_id).uniq.size
    end

    def has_supplementary?
      self.supplementary_ct > 0
    end

    def any?
      self.vuln_ct > 0
    end
  end

  class ChangesPresenter
    attr_accessor :added_ct, :removed_ct, :upgraded_ct, :server_ct

    def initialize(new_changes)
      self.server_ct = new_changes[:server_ct]
      self.added_ct = new_changes[:added_ct]
      self.removed_ct = new_changes[:removed_ct]
      self.upgraded_ct = new_changes[:upgraded_ct]
    end

    def any?
      self.server_ct > 0
    end
  end
end

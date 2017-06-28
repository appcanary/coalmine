class DailySummaryPresenter
  include ActionView::Helpers::TextHelper
  attr_accessor :dsquery, :vulnquery,
                :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns,
                :changes, :server_ct, :inactive_server_ct, :monitor_ct


  delegate :date, :account,
           :all_vuln_ct,
           :all_servers, :new_servers, :deleted_servers,
           :all_monitors, :new_monitors, :deleted_monitors,
           :to => :dsquery

  def initialize(dsquery)
    self.dsquery = dsquery
    self.vulnquery = VulnQuery.new(self.account)

    self.fresh_vulns = VulnCollectionPresenter.new(dsquery.fresh_vulns)
    self.new_vulns = VulnCollectionPresenter.new(dsquery.new_vulns)

    self.patched_vulns = VulnCollectionPresenter.new(dsquery.patched_vulns)
    self.cantfix_vulns = VulnCollectionPresenter.new(dsquery.cantfix_vulns)
    self.changes = ChangesPresenter.new(dsquery.changes)

    self.server_ct = self.all_servers.count
    self.monitor_ct = self.all_monitors.count

    active_server_ct = self.all_servers.active_as_of(self.date).count
    self.inactive_server_ct = self.server_ct - active_server_ct
  end

  def total_vuln_ct
    fresh_vulns.vuln_ct + new_vulns.vuln_ct
  end

  def old_vuln_ct
    self.all_vuln_ct - total_vuln_ct
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
    has_fresh_vulns?       ||
      has_new_vulns?       ||
      has_cantfix_vulns?   ||
      has_new_servers?     ||
      has_deleted_servers? ||
      has_new_monitors?    ||
      has_deleted_monitors?
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
    "Daily Summary for #{self.date}"
  end

  def summary_string
    summaries = []
    if self.has_vulns_to_report?
      summaries << pluralize(self.total_vuln_ct, "new vuln")
    end
    if self.has_patched_vulns?
      summaries << pluralize(self.patched_vulns.vuln_ct, "patched vuln")
    end
    if self.has_new_servers?
      summaries << pluralize(self.new_servers.count, "new server")
    end
    if self.has_new_monitors?
      summaries << pluralize(self.new_monitors.count, "new monitor")
    end
    if self.has_changes?
      summaries << pluralize(self.changes.total_ct, "changed package")
    end

    if summaries.empty?
      "nothing to report"
    else
      summaries.join(", ")
    end
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

  create_collection_has_any_methods :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns,
                                    :changes, :new_servers, :deleted_servers, :new_monitors, :deleted_monitors



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
    attr_accessor :vuln_ct, :package_ct, :server_ct, :sorted_vulns, :package_ids, :server_ids, :supplementary_ct, :monitor_ids, :monitor_ct

    delegate :each, to: :sorted_vulns
    def initialize(coll)
      self.sorted_vulns = sort_group_log_vulns(coll)

      self.vuln_ct = coll.map(&:vulnerability_id).uniq.size
      self.package_ct = coll.map(&:package_id).uniq.size

      self.server_ids = coll.map(&:agent_server_id).select(&:present?).uniq
      self.server_ct = self.server_ids.size

      self.monitor_ids = coll.select{|lbv| lbv.agent_server_id.nil?}.map(&:bundle_id).uniq
      self.monitor_ct = monitor_ids.size

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
    attr_accessor :added_ct, :removed_ct, :upgraded_ct, :server_ct, :monitor_ct

    def initialize(new_changes)
      self.server_ct = new_changes[:server_ct]
      self.monitor_ct = new_changes[:monitor_ct]
      self.added_ct = new_changes[:added_ct]
      self.removed_ct = new_changes[:removed_ct]
      self.upgraded_ct = new_changes[:upgraded_ct]
    end

    def any?
      self.server_ct > 0
    end

    def total_ct
      self.added_ct + self.removed_ct + self.upgraded_ct
    end
  end
end

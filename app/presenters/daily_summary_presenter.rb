class DailySummaryPresenter
  include ActionView::Helpers::TextHelper
  attr_accessor :ds, :vulnquery,
                :fresh_vulns, :new_vulns, :patched_vulns, :cantfix_vulns,
                :changes, :server_ct, :inactive_server_ct, :monitor_ct


  delegate :date, :account,
           :all_vuln_ct,
           :all_servers, :new_servers, :deleted_servers,
           :all_monitors, :new_monitors, :deleted_monitors,
           :to => :ds

  def initialize(ds)
    self.ds = ds
    self.vulnquery = VulnQuery.new(account)

    self.fresh_vulns = VulnCollectionPresenter.new(ds.fresh_vulns_vuln_pkg_ids, ds.fresh_vulns_server_ids, ds.fresh_vulns_monitor_ids, ds.fresh_vulns_package_ids, ds.fresh_vulns_supplementary_count)
    self.new_vulns = VulnCollectionPresenter.new(ds.new_vulns_vuln_pkg_ids, ds.new_vulns_server_ids, ds.new_vulns_monitor_ids, ds.new_vulns_package_ids, ds.new_vulns_supplementary_count)
    self.patched_vulns = VulnCollectionPresenter.new(ds.patched_vulns_vuln_pkg_ids, ds.patched_vulns_server_ids, ds.patched_vulns_monitor_ids, ds.patched_vulns_package_ids, ds.patched_vulns_supplementary_count)
    self.cantfix_vulns = VulnCollectionPresenter.new(ds.cantfix_vulns_vuln_pkg_ids, ds.cantfix_vulns_server_ids, ds.cantfix_vulns_monitor_ids, ds.cantfix_vulns_package_ids, ds.cantfix_vulns_supplementary_count)
    self.changes = ChangesPresenter.new(ds.changes_server_count, ds.changes_monitor_count, ds.changes_added_count, ds.changes_removed_count, ds.changes_upgraded_count)

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


  class VulnCollectionPresenter
    attr_accessor :vuln_ct, :package_ct, :server_ct, :sorted_vulns, :package_ids, :server_ids, :supplementary_ct, :monitor_ids, :monitor_ct

    delegate :each, to: :sorted_vulns
    def initialize(sorted_vuln_pkgs_ids, server_ids, monitor_ids, package_ids, supplementary_ct)
      @sorted_vuln_pkgs_ids = sorted_vuln_pkgs_ids
      self.vuln_ct = sorted_vulns.size
      self.package_ct = package_ids.size

      self.server_ids = server_ids
      self.server_ct = server_ids.size

      self.monitor_ids = monitor_ids
      self.monitor_ct = monitor_ids.size

      self.package_ids = package_ids
      self.supplementary_ct = supplementary_ct
    end

    def sorted_vulns
      @sorted_vulns ||= @sorted_vuln_pkgs_ids.map { |vid, pkg_ids|
        [Vulnerability.find(vid), Package.where(id: pkg_ids)]
      }
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

    def initialize(server_ct, monitor_ct, added_ct, removed_ct, upgraded_ct)
      self.server_ct = server_ct
      self.monitor_ct = monitor_ct
      self.added_ct = added_ct
      self.removed_ct = removed_ct
      self.upgraded_ct = upgraded_ct
    end

    def any?
      self.server_ct > 0
    end

    def total_ct
      self.added_ct + self.removed_ct + self.upgraded_ct
    end
  end
end

class BundlePresenter
  attr_reader :vulnquery, :bundle
  delegate :id, :to_param, :display_name,
    :platform, :created_at, :updated_at, :system_bundle?, :to => :bundle
 
  def initialize(vq, mon)
    @vulnquery = vq
    @bundle = mon
  end

  def vulnerable?
    @bundle.vulnerable_via_vulnquery?
  end

  def vuln_packages
    # assumption: any consumer of this method will want to consume
    # package.upgrade_priority anyways; that value gets cached per
    # object lifetime, so we might as well warm it up here:
    @vuln_packages ||= vulnquery.from_bundle(bundle).sort_by { |p| [-p.upgrade_priority_ordinal, p.name]}
  end

  def all_packages
    @all_packages ||= bundle.packages.order(:name).to_a
  end

  # TODO this is the wrong place to return ignores that aren't anchored to any
  # particular bundle
  def ignored_packages
    @ignored_packages ||= bundle.ignored_packages.
                            select("count(vulnerable_packages.vulnerable_dependency_id) vuln_count",
                                   :id, :user_id, :package_id, :bundle_id, :note).
                            group(:id, :user_id, :package_id, :bundle_id, :note).
                            to_a
  end

  def resolved_package_logs
    @resolved_packages ||= bundle.log_resolutions.
                             select("count(log_resolutions.vulnerable_dependency_id) vuln_count",
                                    :user_id, :package_id, :note).
                             group(:package_id, :user_id, :note).
                             includes(:package, :user).
                             to_a
  end
end

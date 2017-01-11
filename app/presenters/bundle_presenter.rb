class BundlePresenter
  attr_reader :vulnquery, :bundle
  delegate :id, :to_param, :display_name,
    :platform, :created_at, :to => :bundle
 
  def initialize(vq, mon)
    @vulnquery = vq
    @bundle = mon
  end

  def vulnerable?
    @vulnerable_q ||= vulnquery.vuln_bundle?(bundle)
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

  def ignored_package_logs
    @ignored_packages ||= bundle.log_resolutions.select("count(log_resolutions.vulnerable_dependency_id) vuln_count", :user_id, :package_id, :note).group(:package_id, :user_id, :note).includes(:package, :user).to_a
  end
end

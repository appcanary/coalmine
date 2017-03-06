class BundleQuery
  attr_reader :bundle, :revision
  delegate :id, :to_param, :display_name,
    :platform, :created_at, :updated_at, :system_bundle?, :log_resolutions, :to => :bundle

  def initialize(bundle, revision = nil)
    @bundle = bundle
    @revision = revision
  end

  def packages
    if @revision
      fetch_packages(@revision)
    else
      joinquery = BundledPackage.where(:bundle_id => bundle.id)
      Package.joins(:bundled_packages).merge(joinquery)
    end
  end

  def bundled_packages
    if @revision
      BundledPackage.as_of(@revision).where(:bundle_id => bundle.id)
    else
      @bundle.bundled_packages
    end
  end

  def fetch_packages(rev)
    joinquery = BundledPackage.build_as_of(rev)
    Package.joins("INNER JOIN #{joinquery} ON bundled_packages.package_id = packages.id").where('bundled_packages.bundle_id' => bundle.id)
  end

  def affected_packages
    self.packages.affected
  end

  def patchable_packages
    self.packages.affected_but_patchable
  end

  def package_delta(prev_rev)
    prev_pkg = fetch_packages(prev_rev)
    added_pkg = packages.where("packages.id NOT IN (?)", prev_pkg.select("packages.id"))
    removed_pkg = prev_pkg.where("packages.id NOT IN (?)", packages.select("packages.id"))

    [removed_pkg, added_pkg]
  end
end

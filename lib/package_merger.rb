class PackageMerger
  def self.merge_duplicate_packages!
    dupes = Package.joins("inner join packages p2 on packages.platform = p2.platform and packages.name = p2.name and packages.version = p2.version and packages.id != p2.id
                           and (packages.release = p2.release or packages.release is null and p2.release is null)
                           and (packages.arch = p2.arch or packages.arch is null and p2.arch is null)").
              order(:id => :asc).uniq.group_by{ |p| [p.platform, p.release, p.name, p.version, p.arch]}
    # second part of the query is because release and arch is nullable :(
    Package.transaction do
      dupes.each do |k, packages|
        canonical_pkg = packages[0]
        dupe_pkgs = packages[1..-1]
        all_bundles = packages.map(&:bundles).flatten.uniq

        # Make sure all the affected bundles have the canonical package
        all_bundles.each do |b|
          b.packages << canonical_pkg
        end

        # Destroy the extra packages
        dupe_pkgs.each do |p|
          p.destroy!
        end
      end
    end
  end
end

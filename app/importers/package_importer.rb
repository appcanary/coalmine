=begin
pkg_query = Package.select("distinct(packages.id), packages.*, p2.source_name new_source_name").
      joins("inner join (select * from packages where platform = 'ubuntu' and source_name is not null) p2 on packages.platform = p2.platform and packages.name = p2.name and packages.release = p2.release").
      where("packages.source_name is null and packages.created_at <= '2016-10-12 22:11:18.000000'")



pkg_query = Package.select("distinct(packages.id), packages.*, p2.source_name new_source_name").joins("inner join (select * from packages where platform = 'ubuntu' and release = 'trusty' and source_name is not null) p2 on packages.platform = p2.platform and packages.name = p2.name and packages.release = p2.release").where("packages.source_name is null and packages.created_at <= '2016-10-12 22:11:18.000000'");



=end

class PackageImporter
  def initialize(path)
    @platform = "ubuntu"
    @release = "trusty"

    @raw_data = open(path).read
  end

  def import!
    update_local_store!
    raw_packages = fetch_packages
    all_packages = raw_packages.map { |rp| parse(rp) }
    process_packages(all_packages)
  end

  def update_local_store!
    # not everyone needs to do this.
    # benefit of breaking this out
    # is so we can test these classes
    # more readily.
  end

  def fetch_packages
    # This is very similar to the dpkg status parser parser
    # Except for the caring about installed packages part.
    # TODO: merge this this with the dpkg status parser
    @raw_data.split(/\n\n(?!\s)/).map do |package|
      ppairs = package.split(/\n(?!\s)/).map do |line|
        line.split(":", 2).map(&:strip)
      end

      Hash[ppairs]
    end
  end

  def parse(raw_package)
    p = Parcel::Dpkg.new(raw_package)
    # TODO: This is hacky, the Parcel constructor should do this

    p.platform = @platform
    p.release = @release
    return p
  end

  def process_packages(all_packages)
    #Let's not lock the database forever here
    all_packages.in_groups_of(1000, false) do |packages| 
      Package.transaction do
        pm = PackageMaker.new(@platform, @release)
        pm.find_or_create(packages)
      end
    end
  end

  def has_changed?(old_adv, new_adv)
    new_attributes = new_adv.to_advisory_attributes

    # filter out stuff like id, created_at
    old_attributes = old_adv.attributes.slice(*new_adv.relevant_keys)

    # source_text gets serialized in weird ways
    old_attributes != new_attributes.except("source_text")
  end

end

class PackageSetManager
  attr_accessor :account
  def initialize(account)
    @account = account
  end

  def create(opt = {}, package_list)
    package_set = PackageSet.new(:account_id => @account.id,
                        :kind => opt[:kind],
                        :release => opt[:release],
                        :name => opt[:name],
                        :path => opt[:path],
                        :last_crc => opt[:last_crc],
                        :from_api => opt[:from_api])

    # TODO: wrap all of this logic in a transaction, obv
    unless package_set.save
      return [package_set, package_set.errors]
    end

    packages = PackageManager.new(kind, release).parse_list!(package_list)

    return set_packages(package_set, packages)
  end

  def update_packages(package_set_id, package_list)
    package_set = PackageSet.where(:account_id => @account.id).find(package_set_id)

    packages = PackageManager.new(package_set.kind, package_set.release).parse_list!(package_list)

    return set_packages(package_set, packages)
  end

  def update_name(package_set_id, name)
    package_set = PackageSet.where(:account_id => @account.id).find(package_set_id)
    package_set.name = name
    package_set.save

    return [package_set, package_set.errors]
  end

  def delete(package_set_id)
    package_set = PackageSet.where(:account_id => @account.id).find(package_set_id)

    ArchivePackageSet.archive(package_set)
    package_set.destroy
    # package_set.update_column(:deleted_at, Time.now)
  end

  protected
  def set_packages(package_set, packages)
    create_revision!(package_set, packages)

    # todo, optimize into single query obv
    # slash, that plays nicer with revisions?
    package_set.package_sets = packages.map do |p| 
      PackageSet.new(:package_id => p.id,
                     :vulnerability => p.vulnerable?)
    end

    [package_set, package_set.errors]
  end

  def create_revision!(package_set, packages)
    # eh tbd
  end

end

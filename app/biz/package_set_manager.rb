class PackageSetManager
  attr_accessor :account
  def initialize(account)
    @account = account
  end

  def create(opt = {}, package_list)
    package_set = PackageSet.new(:account_id => @account.id,
                        :platform => opt[:platform],
                        :release => opt[:release],
                        :name => opt[:name],
                        :path => opt[:path],
                        :last_crc => opt[:last_crc],
                        :from_api => opt[:from_api])

    # TODO: wrap all of this logic in a transaction, obv
    unless package_set.save
      return [package_set, package_set.errors]
    end

    packages = PackageManager.new(platform, release).find_or_create(package_list)

    return assign_packages!(package_set, packages)
  end

  def update(package_set_id, package_list)
    package_set = PackageSet.where(:account_id => @account.id).find(package_set_id)

    packages = PackageManager.new(package_set.platform, package_set.release).find_or_create(package_list)

    return assign_packages(package_set, packages)
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
  def assign_packages!(package_set, packages)
    create_revision!(package_set, packages)

    # todo, optimize into single query obv
    # slash, that plays nicer with revisions?
 
    # TODO: double check the exact behaviour of this
    package_set.packages = packages

    [package_set, package_set.errors]
  end

  def create_revision!(package_set, packages)
    # eh tbd
  end

end

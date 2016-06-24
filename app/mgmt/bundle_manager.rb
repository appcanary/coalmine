class BundleManager
  attr_accessor :account
  def initialize(account)
    @account = account
  end


  # don't we need a kind alongside platform?
  # platform alone seems insufficient
  # the (keys (group-by :platform (Version/all-with db :platform)))
  # returned shows a lot of variance
  def create(opt = {}, package_list)
    platform, release = opt[:platform], opt[:release]
    bundle = Bundle.new(:account_id => @account.id,
                        :platform => platform,
                        :release => release,
                        :name => opt[:name],
                        :path => opt[:path],
                        :last_crc => opt[:last_crc],
                        :from_api => opt[:from_api])

    # TODO: wrap all of this logic in a transaction, obv
    unless bundle.save
      raise "package set problem to be fixed later"
    end

    packages = PackageManager.new(platform, release).find_or_create(package_list)

    return assign_packages!(bundle, packages)
  end

  def update(bundle_id, package_list)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)

    packages = PackageManager.new(bundle.platform, bundle.release).find_or_create(package_list)

    return assign_packages!(bundle, packages)
  end

  def update_name(bundle_id, name)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)
    bundle.name = name
    
    unless bundle.save
      raise "package set problem, insert msg here"
    end

    return bundle
  end

  def delete(bundle_id)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)

    # TODO: packagelog? archive?
    bundle.destroy
  end

  protected
  def assign_packages!(bundle, packages)
    # TODO: packagelog? archive?
    create_revision!(bundle, packages)

    # todo, optimize into single query obv
    # slash, that plays nicer with revisions?
 
    # TODO: double check the exact behaviour of this
    bundle.packages = packages
    LogBundleVulnerability.record_vulnerable_bundle!(bundle.id)

    bundle
  end

  def create_revision!(bundle, packages)
    # eh tbd
  end

end

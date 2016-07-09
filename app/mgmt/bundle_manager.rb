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

    bundle.transaction do
      unless bundle.save
        raise "problem with bundle to be fixed later"
      end

      packages = PackageManager.new(platform, release).find_or_create(package_list)
      bundle = assign_packages!(bundle, packages)
    end

    bundle
  end

  def update(bundle_id, package_list)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)

    bundle.transaction do
      packages = PackageManager.new(bundle.platform, bundle.release).find_or_create(package_list)
      bundle = assign_packages!(bundle, packages)
    end

    bundle
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

    bundle.destroy
  end

  protected
  def assign_packages!(bundle, packages)
    # this will diff existing BundledPackages
    # and only delete the ones *not in the new set*
    # thereby guaranteeing that two given BundledPackage
    # for the same package but different BP ids will represent
    # different "generations". 
    #
    # behaviour is tested in bundle_test.rb
    bundle.packages = packages

    # A bundle has changed! Time to record any logs
    ReportManager.new(bundle.id).on_bundle_change

    bundle
  end
end

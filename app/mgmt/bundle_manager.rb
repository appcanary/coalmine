class BundleManager < ServiceManager
  attr_accessor :account
  def initialize(account)
    self.account = account
  end

  # don't we need a kind alongside platform?
  # platform alone seems insufficient
  # the (keys (group-by :platform (Version/all-with db :platform)))
  # returned shows a lot of variance
  def create(opt, package_list)
    platform, release = opt[:platform], opt[:release]
    bundle = Bundle.new(:account_id => @account.id,
                        :platform => platform,
                        :release => release,
                        :name => opt[:name],
                        :path => opt[:path],
                        :last_crc => opt[:last_crc],
                        :from_api => opt[:from_api])

    begin
      bundle.transaction do
        bundle.save!

        packages = PackageMaker.new(platform, release).find_or_create(package_list)
        bundle = assign_packages!(bundle, packages)
      end
    rescue ActiveRecord::RecordInvalid => e
      # needs testing
      return Result.new(bundle, e)
    end

    Result.new(bundle)
  end

  def update(bundle_id, package_list)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)

    begin
      bundle.transaction do
        packages = PackageMaker.new(bundle.platform, bundle.release).find_or_create(package_list)
        bundle = assign_packages!(bundle, packages)
      end
    rescue ActiveRecord::RecordInvalid => e
      return Result.new(bundle, e)
    end

    Result.new(bundle)
  end

  def update_name(bundle_id, name)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)
    bundle.name = name
    
    if bundle.save
      Result.new(bundle)
    else
      Result.new(bundle, bundle.errors)
    end
  end

  def delete(bundle_id)
    bundle = Bundle.where(:account_id => @account.id).find(bundle_id)

    if bundle.destroy
      Result.new(bundle)
    else
      Result.new(bundle, bundle.errors)
    end
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

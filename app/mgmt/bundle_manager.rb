class BundleManager < ServiceManager
  attr_accessor :account_id, :server_id
  def initialize(account, server = nil)
    self.account_id = account.id
    self.server_id = server && server.id
  end

  # don't we need a kind alongside platform?
  # platform alone seems insufficient
  # the (keys (group-by :platform (Version/all-with db :platform)))
  # returned shows a lot of variance
  def create(pr, opt, package_list)
    platform, release = pr.platform, pr.release
    bundle = Bundle.new(:account_id => @account_id,
                        :agent_server_id => @server_id,
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

  # TODO: freak out if @server_id is null
  def create_or_update(pr, opt, package_list)
    bundle_id = Bundle.where(:account_id => @account_id, 
                             :agent_server_id => @server_id, 
                             :path => opt[:path]).pluck("id").first


    if bundle_id
      self.update_packages(bundle_id, package_list)
    else
      self.create(pr, opt, package_list)
    end
  end

  def update_packages(bundle_id, package_list)
    bundle = Bundle.where(:account_id => @account_id).find(bundle_id)

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
    bundle = Bundle.where(:account_id => @account_id).find(bundle_id)
    bundle.name = name

    if bundle.save
      Result.new(bundle)
    else
      Result.new(bundle, bundle.errors)
    end
  end

  # do we care, really?
  def update_on_heartbeat(path, attributes = {})
    begin
      bundle = Bundle.where(:account_id => @account_id, :path => path).take!

      if bundle.being_watched != attributes[:"being-watched"]
        bundle.being_watched = attributes[:"being-watched"]
      end

      if bundle.save
        Result.new(bundle)
      else
        Result.new(bundle, bundle.errors)
      end

    rescue ActiveRecord::RecordNotFound => e
      return Result.new(nil, e)
    end

  end

  def delete(bundle_id)
    bundle = Bundle.where(:account_id => @account_id).find(bundle_id)

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
    ReportMaker.new(bundle.id).on_bundle_change

    bundle
  end
end

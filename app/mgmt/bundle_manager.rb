class BundleManager < ServiceManager
  attr_accessor :account, :account_id, :server_id
  def initialize(account, server = nil)
    self.account = account
    self.account_id = self.account.id
    self.server_id = server && server.id
  end

  # TODO: throw exception if package_list is empty?
  # TODO: i feel like this - or some other class - 
  # should be responsible for *finding* the right bundle
  # scoped by account or server

  def create(pr, opt, package_list)
    platform, release = pr.platform, pr.release
    bundle = Bundle.new(:account_id => @account_id,
                        :agent_server_id => @server_id,
                        :platform => platform,
                        :release => release,
                        :name => opt[:name],
                        :path => opt[:path],
                        :last_crc => opt[:last_crc],
                        :from_api => opt[:from_api],
                        :created_at => opt[:created_at])

    begin
      bundle.transaction do
        bundle.save!

        if $rollout.active?(:update_all_packages)
          packages = PackageMaker.new(platform, release, "user", true).find_or_create(package_list)
        else
          packages = PackageMaker.new(platform, release).find_or_create(package_list)
        end
        bundle = assign_packages!(bundle, packages)
      end
    rescue ActiveRecord::RecordInvalid => e
      # needs testing
      return Result.new(bundle, e)
    end

    $analytics.added_bundle(account, bundle)
    Result.new(bundle)
  end

  def create_or_update(pr, opt, package_list)
    raise ArgumentError.new("Server id can't be nil") if @server_id.nil? 

    bundle_id = Bundle.where(:account_id => @account_id, 
                             :agent_server_id => @server_id,
                             :name => opt[:name],
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

    $analytics.updated_bundle(account, bundle)

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

  # TODO: dead code
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
      $analytics.deleted_bundle(account, bundle)
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

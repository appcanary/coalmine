# This will log stuff to our que log, I assume this is right for this job
class AgentUpdateJob < Jobber
  def run(account_id, server_id, platform, release, bundle_opt, package_list)
    account = Account.find(account_id)
    server = AgentServer.find(server_id)
    log "Updating #{account.email} - #{server_id}"
    # Load package list back into Parcels (instead of an array of hashes)
    package_list = package_list.map{|p| Parcel.for_platform(platform).builder_from_hsh(p)}
    pr, err = PlatformRelease.validate(platform, release)
    if err
      # The agent controller should have caught this!
      raise err
    end

    bm = BundleManager.new(account, server)
    bm.create_or_update(pr, bundle_opt, package_list)
  end
end

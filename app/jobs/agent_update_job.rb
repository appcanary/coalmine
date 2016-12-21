# This will log stuff to our que log, I assume this is right for this job
class AgentUpdateJob < Jobber
  def run(account_id, server_id, pr, bundle_opt, package_list_marshaled)
    bm = BundleManager.new(Account.find(account_id), AgentServer.find(server_id))
    bm.create_or_update(pr, bundle_opt, Marshal.load(package_list_marshaled))
  end
end

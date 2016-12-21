# This will log stuff to our que log, I assume this is right for this job
class AgentUpdateJob < Jobber
  def run(account_id, server_id, pr_marshaled, bundle_opt, package_list_marshaled)
    # I don't love marshaling these, but it's the right thing for now
    pr = Marshal.load(pr_marshaled)
    package_list = Marshal.load(package_list_marshaled)
    bm = BundleManager.new(Account.find(account_id), AgentServer.find(server_id))
    bm.create_or_update(pr, bundle_opt, package_list)
  end
end

class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @vulnquery = VulnQuery.new(current_account)
    @server, @bundle = fetch_server_and_bundle(params)
    @bundlepres = BundlePresenter.new(@vulnquery, @bundle)
  end

  # should ideally confirm it belongs to the same server
  # but... it's fine, scoped to account.
  def destroy
    @bm = BundleManager.new(current_user.account)

    res, error = @bm.delete(params[:id])

    if error
      redirect_to server_path(params[:server_id]), notice: "Sorry, something went wrong."
    else
      redirect_to server_path(params[:server_id]), notice: "OK. Your app was deleted. You should no longer receive notifications."
    end
  end

  protected
  def fetch_server_and_bundle(params)
    if current_user.is_admin?
      server = AgentServer.find(params[:server_id])
      bundle = Bundle.where(:agent_server_id => params[:server_id]).find(params[:id])
    else
      server = current_user.agent_servers.find(params[:server_id])
      bundle = current_user.bundles.where(:agent_server_id => params[:server_id]).find(params[:id])
    end
    [server, bundle]
  end
end

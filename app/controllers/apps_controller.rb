class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @vulnquery = VulnQuery.new(current_account)
    @bundlepres = BundlePresenter.new(@vulnquery, bundle)
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
  def server
    if current_user.is_admin?
      @server ||= AgentServer.find(params[:server_id])
    else
      @server ||= current_user.agent_servers.find(params[:server_id])
    end
  end

  def bundle
    if current_user.is_admin?
      @bundle ||= Bundle.where(:agent_server_id => params[:server_id]).find(params[:id])
    else
      @bundle ||= current_user.bundles.where(:agent_server_id => params[:server_id]).find(params[:id])
    end
  end
end

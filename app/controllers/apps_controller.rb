class AppsController < ApplicationController
  def index
    raise ActionController::RoutingError.new("nope")
  end

  def new
  end

  def show
    @vulnquery = VulnQuery.new(current_account)
    @server = current_user.agent_servers.find(params[:server_id])
    b = current_user.bundles.where(:agent_server_id => params[:server_id]).find(params[:id])
    @bundle = BundlePresenter.new(@vulnquery, b)

    @packages = @bundle.packages.order(:name)
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

end

class MonitorsController < ApplicationController
  def show
    @monitor = monitor
    @vuln_artifacts = @monitor.vulnerable_versions
    @artifacts = []
  end


  def destroy
    if Moniter.destroy(current_user, params[:id])
      redirect_to dashboard_path, notice: "OK. Your monitor was deleted. "
    else
      redirect_to dashboard_path, notice: "Sorry, something went wrong. Please try again."
    end
  end

  protected
  def monitor
    Moniter.find(current_user, params[:id])
  end
end

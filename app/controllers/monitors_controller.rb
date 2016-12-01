class MonitorsController < ApplicationController
  def show
    bundle = current_user.bundles.via_api.find(params[:id])

    @bundlepres = BundlePresenter.new(VulnQuery.new(current_account), bundle)
  end

  def new
    @form = MonitorForm.new(Bundle.new)
  end

  def create
    @form = MonitorForm.new(Bundle.new)

    if @form.validate(params[:monitor])
      
      @bm = BundleManager.new(current_user.account)
      @bundle, error = @bm.create(@form.platform_release, {name: @form.name}, @form.package_list)

      if error
        @form.errors.add(:base, error.message)
      end
    end

    if @form.errors.empty?
      redirect_to dashboard_path
    else
      render :new
    end
  end


  def destroy
    @bm = BundleManager.new(current_user.account)

    res, error = @bm.delete(params[:id])

    if error
      redirect_to dashboard_path, notice: "Sorry, something went wrong."
    else
      redirect_to dashboard_path, notice: "OK. Your monitor was deleted."
    end
  end

  def resolve_vuln
    pkg = Package.find(resolution_params[:package_id])
    LogResolution.resolve_package(current_user, pkg, resolution_params[:note])
    redirect_to :back, notice: "Package successfully marked as resolved."
  end

  def unresolve_vuln
    pkg = Package.find(resolution_params[:package_id])
    LogResolution.delete_with_package(current_user, pkg)
    redirect_to :back, notice: "Package successfully marked as not resolved."
  end

  def resolution_params
    params.require(:log_resolution).permit(:package_id, :note)
  end

end

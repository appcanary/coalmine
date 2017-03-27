class MonitorsController < ApplicationController
  def show
    @bundle = fetch_bundle(params)
    @bundlepres = BundlePresenter.new(VulnQuery.new(current_account), @bundle)
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

  def ignore_vuln
    pkg = Package.find(ignore_params[:package_id])
    IgnoredPackage.ignore_package(current_user, pkg, maybe_fetch_bundle, ignore_params[:note])
    redirect_to :back, notice: "Package successfully marked ignored."
  end

  def unignore_vuln
    IgnoredPackage.unignore_package(current_user, ignore_params[:ignored_package_id])
    redirect_to :back, notice: "Package successfully marked unignored."
  end

  def resolve_vuln
    pkg = Package.find(resolution_params[:package_id])
    LogResolution.resolve_package(current_user, pkg, resolution_params[:note])
    redirect_to :back, notice: "Package successfully marked 'wontfix'."
  end

  def unresolve_vuln
    pkg = Package.find(resolution_params[:package_id])
    LogResolution.delete_with_package(current_user, pkg)
    redirect_to :back, notice: "Package successfully unmarked 'wontfix'."
  end

  def resolution_params
    params.require(:log_resolution).permit(:package_id, :note)
  end

  def ignore_params
    params.require(:ignored_package).permit(:package_id, :note, :bundle_id, :global, :ignored_package_id)
  end

  protected
  def maybe_fetch_bundle
    if ignore_params[:global] != "yes" && ignore_params[:bundle_id].present?
      Bundle.find(ignore_params[:bundle_id])
    end
  end

  def fetch_bundle(params)
    if current_user.is_admin?
      Bundle.via_api.find(params[:id])
    else
      current_user.bundles.via_api.find(params[:id])
    end
  end

end

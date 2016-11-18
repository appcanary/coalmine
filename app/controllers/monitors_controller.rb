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

  def ignore_vuln
    if params[:package_id].present?
      LogResolution.resolve_package!(current_user, Package.find(params[:package_id]))
      redirect_to :back, notice: "done!"
    else
      redirect_to :back, notice: "something went wrong"
    end
  end

end

class MonitorsController < ApplicationController
  def show
    @form = MonitorForm.new(Bundle.new)
    @bundle = current_user.bundles.via_api.find(params[:id])

    @artifacts = @bundle.packages
    @vuln_artifacts = PackageReport.from_bundle(@bundle)
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

    if @form.valid?
      redirect_to dashboard_path
    else
      render :new
    end
  end


  def destroy
    @bundle = current_user.bundles.via_api.find(params[:id])

    @bundle.destroy
    redirect_to dashboard_path, notice: "OK. Your monitor was deleted."
  end

end

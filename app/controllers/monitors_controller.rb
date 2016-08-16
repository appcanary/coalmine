class MonitorsController < ApplicationController
  def show
    @form = MonitorForm.new(Bundle.new)
    @vuln_artifacts = @monitor.vulnerable_versions
    @artifacts = []
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

  def monitor_params
    params.require(:moniter).permit(:name, :platform_release, :file)
  end

  def invalid_params?(pr, file)
    errors = []

    if pr.blank?
      errors << "Invalid platform selection. Please try again."
    end

    if file.blank?
      errors << "Are you sure you uploaded a file? Try again!"
    end

    if errors.present?
      return errors
    else
      return false
    end
  end
end

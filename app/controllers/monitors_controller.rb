class MonitorsController < ApplicationController
  def show
    @monitor = monitor
    @vuln_artifacts = @monitor.vulnerable_versions
    @artifacts = []
  end

  def new
    @monitor = Moniter.new
  end

  def create
    @monitor = Moniter.new

    pr = Platforms.select_opt_to_h(monitor_params[:platform_release])
    file = monitor_params[:file]

    if error = invalid_params?(pr, file)
      @monitor.errors = error
    else
      name = monitor_params[:name]

      begin
        Moniter.create(current_user, file, pr, name)
      rescue CanaryClient::ClientError => e
        @monitor.errors = e.body["errors"].map { |e| e["title"]["message"] || e["title"]}
      end
    end

    if @monitor.errors.present?
      render :new
    else
      redirect_to dashboard_path
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

class Api::MonitorsController < ApiController
  def index
    @bundles = current_account.bundles.via_api

    render json: @bundles, adapter: :json_api
  end

  def create
    @form = ApiMonitorForm.new(Bundle.new)

    if @form.validate(params)
      
      @bm = BundleManager.new(current_account)
      @bundle, error = @bm.create(@form.platform_release, {name: @form.name}, @form.package_list)

      if error
        @form.errors.add(:base, error.message)
      end
    end

    if @form.errors.empty?
      register_api_call!

      render json: @bundle, adapter: :json_api
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end

  def update
    @bundle = current_account.bundles.via_api.where(:name => params[:name]).take
    @form = ApiMonitorForm.new(@bundle || Bundle.new)

    if @bundle && @form.validate(params)
      @bm = BundleManager.new(current_account)
      @bundle, error = @bm.update_packages(@bundle.id, @form.package_list)

      if error
        @form.errors.add(:base, error.message)
      end
    end

    if @bundle.nil?
      render json: {errors: [{title: "No monitor with that name was found"}]}, adapter: :json_api, status: :not_found
    elsif @form.errors.present?
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    else
      register_api_call!
      render json: @bundle, adapter: :json_api
    end
  end

  def show
    @bundle = current_account.bundles.via_api.where(:name => params[:name]).take

    if @bundle
      register_api_call!
      render json: @bundle, adapter: :json_api, serializer: BundleWithVulnsSerializer, include: ["packages", "vulnerabilities"]
    else
      render json: {errors: [{title: "No monitor with that name was found"}]}, adapter: :json_api, status: :not_found
    end
  end


  def destroy
    @bundle = current_account.bundles.via_api.where(:name => params[:name]).take

    if @bundle.nil?
      render json: {errors: [{title: "No monitor with that name was found"}]}, adapter: :json_api, status: :not_found
    elsif @bundle.destroy
      register_api_call!
      render :nothing => true, :status => 204
    else
      render json: {errors: [{title: "Monitor deletion failed."}]}, adapter: :json_api, status: 500
    end
  end

end

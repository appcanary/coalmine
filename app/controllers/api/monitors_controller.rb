class Api::MonitorsController < ApiController
 
  def index
    @bundles = current_account.bundles.via_api

    render json: @bundles, adapter: :json_api
  end

  def create
    @form = ApiForm.new(Bundle.new)

    if @form.validate(params)
      
      @bm = BundleManager.new(current_account)
      @bundle, error = @bm.create(@form.platform_release, {name: @form.name}, @form.package_list)

      if error
        @form.errors.add(:base, error.message)
      end
    end

    if @form.errors.empty?
      render json: @bundle, adapter: :json_api
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end

  def update
    @form = ApiForm.new(Bundle.new)

    @bundle = current_account.bundles.via_api.where(:name => params[:name]).take

    if @bundle && @form.validate(params)
      @bm = BundleManager.new(current_account)
      @bundle, error = @bm.update_packages(bundle.id, @form.package_list)

      if error
        @form.errors.add(:base, error.message)
      end
    end

    if bundle.nil?
      render json: {errors: [{title: "No monitor with that name was found"}]}, adapter: :json_api, status: :not_found
    elsif @form.errors.empty?
      render json: @bundle, adapter: :json_api
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end

  def show
    @bundle = current_account.bundles.via_api.where(:name => params[:name]).take

    if @bundle
      render json: @bundle, adapter: :json_api, serializer: BundleWithVulnsSerializer, include: ["vulnerable_packages", "vulnerabilities"]
    else
      render json: {errors: [{title: "No monitor with that name was found"}]}, adapter: :json_api, status: :not_found
    end
  end


  def destroy
    @bundle = current_user.bundles.via_api.find(params[:id])

    if @bundle.nil?
      render json: {errors: [{title: "No monitor with that name was found"}]}, adapter: :json_api, status: :not_found
    elsif @bundle.destroy
      render :nothing => true, :status => 204
    else
      render json: {errors: [{title: "Monitor deletion failed."}]}, adapter: :json_api, status: 500
    end
  end

end

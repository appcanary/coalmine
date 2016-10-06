class Api::MonitorsController < ApiController
  def index
    @bundles = current_account.bundles.via_api

    handle_api_response(@bundles)
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

      handle_api_response(@bundle)
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end

  def update
    @bundle = fetch_bundle

    @form = ApiMonitorForm.new(@bundle || Bundle.new)

    if @bundle && @form.validate(params)
      @bm = BundleManager.new(current_account)
      @bundle, error = @bm.update_packages(@bundle.id, @form.package_list)

      if error
        @form.errors.add(:base, error.message)
      end
    end

    if @bundle.nil?
      render json: {errors: [{title: "No monitor with that name or id was found"}]}, adapter: :json_api, status: :not_found
    elsif @form.errors.present?
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    else
      register_api_call!
      handle_api_response(@bundle)
    end
  end

  def show
    @bundle = fetch_bundle

    if @bundle
      register_api_call!
      handle_api_response(@bundle)
    else
      render json: {errors: [{title: "No monitor with that name or id was found"}]}, adapter: :json_api, status: :not_found
    end
  end


  def destroy
    @bundle = fetch_bundle

    if @bundle.nil?
      render json: {errors: [{title: "No monitor with that name or id was found"}]}, adapter: :json_api, status: :not_found
    elsif @bundle.destroy
      register_api_call!
      render :nothing => true, :status => 204
    else
      render json: {errors: [{title: "Monitor deletion failed."}]}, adapter: :json_api, status: 500
    end
  end

  def fetch_bundle
    bundle = current_account.bundles.via_api.where(:name => params[:name]).take
    bundle ||= current_account.bundles.via_api.where(:id => params[:name]).take
  end

  def handle_api_response(bundle)
    if v2_request?
      # TODO TEST
      if action_name == "show"
        resp = ApiV2MonitorResponseSerializer.new(bundle, :show_action => true)
      else
        resp = ApiV2MonitorResponseSerializer.new(bundle)
      end

      render json: resp.to_json
    else
      if action_name == "show"
        render json: bundle, adapter: :json_api, serializer: BundleWithVulnsSerializer, include: ["packages", "vulnerabilities"]
      else
        render json: bundle, adapter: :json_api
      end
    end
  end

end

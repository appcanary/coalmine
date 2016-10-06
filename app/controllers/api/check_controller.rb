class Api::CheckController < ApiController
  def create
    @form = ApiForm.new(Bundle.new)

    if @form.validate(params)
      package_query = nil
      package_list = @form.package_list
      p = @form.platform_release.platform
      r = @form.platform_release.release

      Package.transaction do
        package_query = PackageMaker.new(p, r).find_or_create(package_list)
      end

      vuln_packages = VulnQuery.from_packages(package_query)

      resp = handle_api_response(request.path, vuln_packages)

      register_api_call!

      render json: resp
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end

  def handle_api_response(path, vuln_packages)
    # TODO TEST
    if v2_request?
      # when calling serializers directly,
      # have to force json here - has to do
      # with how AMS handles the render :json call below
      resp = ApiV2CheckResponseSerializer.new(vuln_packages).to_json
    else
      resp = PackageVulnerabilityResponse.new(vuln_packages)
    end
  end
end

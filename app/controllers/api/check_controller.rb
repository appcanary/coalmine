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
      resp = PackageVulnerabilityResponse.new(vuln_packages)
 
      register_api_call!

      render json: resp
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end
end

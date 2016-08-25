class Api::CheckController < ApiController
  def create
    @form = ApiForm.new(Bundle.new)

    if @form.validate(params)
      package_query = nil
      package_list = @form.package_list

      Package.transaction do
        package_query = PackageMaker.new(Platforms::Ruby, nil).find_or_create(package_list)
      end

      vuln_packages = VulnQuery.from_packages(package_query)
      resp = PackageVulnerabilityResponse.new(vuln_packages)
      render json: resp
    else
      render json: errors_to_h(@form.errors), adapter: :json_api, status: :bad_request
    end
  end
end

class Api::CheckController < ApiController
  # TODO: test
  def create
    @form = ApiForm.new(Object.new)

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
      render json: @form, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end
end

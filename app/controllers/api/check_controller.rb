class Api::CheckController < ApiController
  def create
    @checker = Checker.new({}, params)

    # TODO: errors, et al
    query = @checker.check(params[:file].read)
    
    resp = PackageVulnerabilityResponse.new(query)

    render json: resp
  end
end

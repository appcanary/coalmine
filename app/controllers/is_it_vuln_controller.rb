class IsItVulnController < ApplicationController
  skip_before_filter :require_login
  layout 'isitvuln'
  def index
    @preuser = PreUser.new
  end

  def submit

    @form = IsItVulnForm.new(Object.new)

    if @form.validate(params)
      result = IsItVulnResult.create(result: @form.package_list)
    end

     respond_to do |format|
      format.json { 
        if @form.errors.blank?
          render json: {id: result.ident}
        else
          render json: {error: @form.errors.full_messages.first}, status: 400
        end
      }
    end
  end

  def results
    @preuser = PreUser.new

    ivr = IsItVulnResult.where(ident: params[:ident]).first

    if ivr.result.nil?
      redirect_to vuln_root_path, flash: {error: "Are you sure you uploaded a file?"}
    else
      package_query = nil
      package_list = ivr.result

      Package.transaction do
        package_query = PackageMaker.new(Platforms::Ruby, nil).find_or_create(package_list)
      end

      @package_reports = PackageReport.from_packages(package_query)
      @package_reports_by_pkg = @package_reports.group_by(&:package)

      @is_vuln = @package_reports.present?
    end
  end


  def sample_results
    @preuser = PreUser.new

    package_list = IsItVulnResult.sample_package_list
    package_query = nil
    Package.transaction do
      package_query = PackageMaker.new(Platforms::Ruby, nil).find_or_create(package_list)
    end

    @package_reports = PackageReport.from_packages(package_query)
    @package_reports_by_pkg = @package_reports.group_by(&:package)

    @is_vuln = @package_reports.present?
    render :results
  end
end

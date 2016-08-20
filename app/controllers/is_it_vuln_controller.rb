class IsItVulnController < ApplicationController
  class EmptyFileError < StandardError
  end

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
        if @form.valid?
          render json: {id: result.ident}
        else
          render json: {error: @form.errors.full_messages.first}, status: 400
        end
      }
    end
  end

  def results
    PackageBuilder
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

      @vuln_artifacts = PackageReport.from_packages(package_query)
      @vuln_artifacts = @vuln_artifacts.group_by(&:package)

      @is_vuln = @vuln_artifacts.present?
    end
  end


  def sample_results
    @preuser = PreUser.new

    package_list = IsItVulnResult.sample_package_list
    package_query = nil
    Package.transaction do
      package_query = PackageMaker.new(Platforms::Ruby, nil).find_or_create(package_list)
    end

    @vuln_artifacts = PackageReport.from_packages(package_query)
    @vuln_artifacts = @vuln_artifacts.group_by(&:package)

    @is_vuln = @vuln_artifacts.present?
    render :results
  end


  protected
  def handle_file_upload(file)
    raise EmptyFileError if file.blank?

    file_contents = file.read
    all_artifacts = Backend.upload_gemfile(file_contents)

    raise ArgumentError if all_artifacts.blank?

    all_artifacts
  end
end

class IsItVulnController < ApplicationController
  class EmptyFileError < StandardError
  end

  skip_before_filter :require_login
  layout 'isitvuln'
  def index
    @preuser = PreUser.new
  end

  def submit
    begin
      all_artifacts = handle_file_upload(params[:file])
      result = IsItVulnResult.create(result: all_artifacts)
    rescue EmptyFileError
      error = 'Hey, you have to upload a file for this to work!'
    rescue ArgumentError
      error = 'Sorry. Are you sure that was a Gemfile.lock? Please try again.'
    rescue Exception
      error = "Something went wrong. Please try again."
    end

    respond_to do |format|
      format.json { 
        if error
          render json: {error: error}, status: 400
        else
          render json: {id: result.ident}
        end
      }
    end
  end

  def results
    @preuser = PreUser.new

    result = IsItVulnResult.where(ident: params[:ident]).first
    if result.nil?
      redirect_to vuln_root_path, flash: {error: "Are you sure you uploaded a file?"}
    else
      all_artifacts = result.result
      @vuln_artifacts = all_artifacts.select(&:is_vulnerable?)

      @is_vuln = @vuln_artifacts.present?
    end
  end


  def sample_results
    @preuser = PreUser.new

      @vuln_artifacts = Testvuln.artifact_versions

      @is_vuln = @vuln_artifacts.present?
      render :results
  end


  protected
  def handle_file_upload(file)
    raise EmptyFileError if file.blank?

    file_contents = file.read
    all_artifacts = Canary.new.upload_gemfile(file_contents)

    raise ArgumentError if all_artifacts.blank?

    all_artifacts
  end
end

class IsItVulnController < ApplicationController
  class EmptyFileError < StandardError
  end

  skip_before_filter :require_login
  layout 'isitvuln'
  def index
    @preuser = PreUser.new
  end

  def results
    begin
      @preuser = PreUser.new

      all_artifacts = handle_file_upload(params[:file])
      @vuln_artifacts = all_artifacts.select(&:is_vulnerable?)

      @is_vuln = @vuln_artifacts.present?
    rescue EmptyFileError
      redirect_to vuln_root_path, flash: {error:'Hey, you have to upload a file for this to work!'}
    rescue ArgumentError
      redirect_to vuln_root_path, flash: {error:'Sorry. Are you sure that was a Gemfile.lock? Please try again.'}
    end
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

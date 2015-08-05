class IsItVulnController < ApplicationController
  skip_before_filter :require_login
  layout 'isitvuln'
  def index
    @preuser = PreUser.new
    if params[:error]
      flash[:error] = 'Sorry. Are you sure that was a Gemfile.lock? Please try again.'
    end
  end

  def results
    if params[:nope]
      @vuln_artifacts = []
    else
      @vuln_artifacts = Testvuln.artifact_versions
    end

    @is_vuln = @vuln_artifacts.present?
    @preuser = PreUser.new
  end
end

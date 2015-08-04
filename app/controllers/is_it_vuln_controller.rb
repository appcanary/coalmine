class IsItVulnController < ApplicationController
  skip_before_filter :require_login
  layout 'isitvuln'
  def index
    @preuser = PreUser.new
  end

  def results
    @vuln_artifacts = Testvuln.artifact_versions
    @preuser = PreUser.new
  end
end

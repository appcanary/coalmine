class IsItVulnController < ApplicationController
  skip_before_filter :require_login
  layout 'isitvuln'
  def index
  end
end

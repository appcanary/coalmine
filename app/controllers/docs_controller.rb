class DocsController < ApplicationController
  skip_before_filter :require_login
  def index
    # temporary
    raise "SENTRY WORKS"
    @agent_token = current_user ? current_user.token : "<YOUR_TOKEN_HERE>"
  end
end

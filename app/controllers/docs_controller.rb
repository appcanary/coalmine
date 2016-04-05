class DocsController < ApplicationController
  skip_before_filter :require_login
  def index
    @agent_token = current_user ? current_user.agent_token : "<YOUR_TOKEN_HERE>"
  end
end

class DocsController < ApplicationController
  skip_before_filter :require_login
  FakeUser = Struct.new(:agent_token)
  def index
    @user = current_user || FakeUser.new("<YOUR_TOKEN_HERE>")
  end
end

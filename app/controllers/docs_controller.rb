class DocsController < ApplicationController
  skip_before_filter :require_login
  def index
    @agent_token = current_user ? current_user.token : "<YOUR_TOKEN_HERE>"
  end

  def api
    @agent_token = current_user ? current_user.token : "<YOUR_TOKEN_HERE>"
  end

  def ci
    @agent_token = current_user ? current_user.token : "<YOUR_TOKEN_HERE>"
  end

  def agent_upgrade
    @upgrade_date = Date.new(2017,6,14)
    @version = "0.1.0-2017.06.14-201711-UTC"
    @chef_version = "0.4.0"
    @puppet_version = "0.2.0"
    @ansible_version = "0.2.0"
  end
end

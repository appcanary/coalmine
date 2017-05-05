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
    @upgrade_date = Date.new(2017,5,8)
    @version = "AGENT VERSION"
    @chef_version = "CHEF VERSION"
    @puppet_version = "PUPPET VERSION"
    @ansible_version = "ANSIBLE VERSION"
  end
end

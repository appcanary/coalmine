class ServersController < ApplicationController
  skip_before_filter :require_login, :only => :install
  def new
    @agent_token = current_user.agent_token
  end

  def show
    server
  end

  def install
    send_file File.join(Rails.root, "lib/assets/script.deb.sh"),
      :filename => "appcanary.debian.sh",
      :type => "text/x-shellscript",
      :disposition => :inline
  end

  def destroy
    if server.destroy
      redirect_to dashboard_path
    end
  end

  protected

  def server
    @server ||= current_user.server(params[:id])
  end
end

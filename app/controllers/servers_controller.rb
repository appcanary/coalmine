class ServersController < ApplicationController
  skip_before_filter :require_login, :only => :install
  def new
    @agent_token = current_user.agent_token
  end

  def onboarding
    @hide_sidebar = true
    @agent_token = current_user.agent_token
    
    render :new
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
      redirect_to dashboard_path, notice: "OK. Do remember to turn off the agent!"
    end
  end

  def edit
    server
  end

  def update
    respond_to do |format|
      if server.update(server_params)
        format.html { redirect_back_or_to(dashboard_path) }
      else
        format.html { render :edit }
      end
    end
  end

  protected

  def server
    @server ||= current_user.server(params[:id])
  end

  def server_params
    params.require(:server).permit(:name)
  end
end

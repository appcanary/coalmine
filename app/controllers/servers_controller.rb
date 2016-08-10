class ServersController < ApplicationController
  skip_before_filter :require_login, :only => [:deb, :rpm, :install]
  def new
    @agent_token = current_user.token
    # @artifacts_count = Backend.artifacts_count
    # @vulnerabilities_count = Backend.vulnerabilities_count
  end

  def onboarding
    @agent_token = current_user.token

    render :new
  end

  def show
    server
    respond_to do |format|
      format.html
      format.csv do
        apps = @server.apps.map { |a| App.find(current_user, @server.uuid, a.uuid) }
        send_data *ServerExporter.new(@server, apps).to_csv
      end
    end
  end

  def install
    send_file File.join(Rails.root, "lib/assets/script.deb.sh"),
      :filename => "appcanary.debian.sh",
      :type => "text/x-shellscript",
      :disposition => :inline
  end

  def deb
    send_file File.join(Rails.root, "lib/assets/script.deb.sh"),
      :filename => "appcanary.debian.sh",
      :type => "text/x-shellscript",
      :disposition => :inline
  end

  def rpm
    send_file File.join(Rails.root, "lib/assets/script.rpm.sh"),
      :filename => "appcanary.debian.sh",
      :type => "text/x-shellscript",
      :disposition => :inline
  end


  def destroy
    if server.destroy
      redirect_to dashboard_path, notice: "OK. Do remember to turn off the agent!"
    end
  end

  def destroy_inactive
    @servers = Server.find_all(current_user)
    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)

    @silent_servers.each(&:destroy)

    flash[:notice] = "All of your inactive servers were deleted."
    redirect_to dashboard_path
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
    @server ||= Server.find(current_user, params[:id])
  end

  def server_params
    params.require(:server).permit(:name)
  end
end

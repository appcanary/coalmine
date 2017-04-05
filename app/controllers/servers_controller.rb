class ServersController < ApplicationController
  skip_before_filter :require_login, :only => [:deb, :rpm, :install]
  def new
    @agent_token = current_user.token
  end

  def onboarding
    @agent_token = current_user.token

    render :new
  end

  def procs
    setup_process_ivars
  end

  def show
    setup_process_ivars

    respond_to do |format|
      format.html
      format.csv do
        vuln_reports = @server.bundles.map { |b| [b, @vulnquery.from_bundle(b)] }
        send_data *ServerExporter.new(@server, vuln_reports).to_csv
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
    @server = fetch_server(params)
    if @server.destroy
      $analytics.deleted_server(current_user.account, @server)
      redirect_to dashboard_path, notice: "OK. Do remember to turn off the agent!"
    end
  end

  # TODO lol what happens to bundles?
  def destroy_inactive
    @servers = current_user.agent_servers
    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)

    @silent_servers.each(&:destroy)

    flash[:notice] = "All of your inactive servers were deleted."
    redirect_to dashboard_path
  end

  def edit
    @server = fetch_server(params)
  end

  def update
    @server = fetch_server(params)
    respond_to do |format|
      if @server.update(server_params)
        @server.destructively_update_tags!(tags_from_params)
        format.html { redirect_back_or_to(dashboard_path) }
      else
        format.html { render :edit }
      end
    end
  end

  protected

  def setup_process_ivars
    @account = current_account # used for rollout
    @vulnquery = VulnQuery.new(@account)

    @server = fetch_server(params)
    @serverpres = ServerPresenter.new(@vulnquery, @server)

    @outdated_procs = @serverpres.outdated_processes
    @all_procs = @serverpres.all_processes

    pr, err = @server.platform_release
    @platform = pr.platform
    @release = pr.release
  end

  def fetch_server(params)
    if current_user.is_admin?
      AgentServer.find(params[:id])
    else
      current_user.agent_servers.find(params[:id])
    end
  end

  def server_params
    params.require(:server).permit(:name)
  end

  def tags_from_params
    tag_params = params.require(:server).permit(tags: [])

    # if it's just empty, we can return it
    unless tag_params[:tags].nil?
      tag_params[:tags].reject(&:empty?)
    end
  end
end

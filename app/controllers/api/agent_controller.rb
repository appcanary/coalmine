class Api::AgentController < ApiController
  # TODO: test current_account scoping, i.e. unauth access?

  def heartbeat
    server = current_account.agent_servers.where(:uuid => params[:uuid]).includes(:agent_release).take

    # TODO log this?
    unless server
      render :text => "", :status => 404
      return
    end

    # TODO: what do we need to update?
    server.transaction do
      server.last_heartbeat_at = Time.now
      server.heartbeats.create!(:files => heartbeat_params[:files], :created_at => server.last_heartbeat_at)

      agent_version = heartbeat_params[:"agent-version"]
      server.agent_release = AgentRelease.where(:version => agent_version).first_or_create

      server.save!
    end

    render json: {heartbeat: server.last_heartbeat_at}
  end

  def create
    server = current_account.agent_servers.create!(create_params).reload
    render :json => {uuid: server.uuid}
  end

  def update
    server = current_account.agent_servers.where(:uuid => params[:uuid]).take
    unless server
      render :text => "", :status => 404
      return
    end

    pr, err = fetch_pr_from_server(sendfile_params, server)
    # TODO: log or show error
    if err
      log_faulty_request(server)
      render :text => "", :status => 400
      return
    end


    parser = Platforms.parser_for(pr.platform)
    file = Base64.decode64(sendfile_params[:contents])

    package_list, err = parser.parse(file)

    # TODO: log or show error?
    if err
      log_faulty_request(server)
      render :text => "", :status => 400
      return
    end

    bundle_opt = {name: sendfile_params[:name], 
                  path: sendfile_params[:path],
                  last_crc: sendfile_params[:crc]}

    bm = BundleManager.new(current_account, server)
    bundle, err = bm.create_or_update(pr, bundle_opt, package_list)
    
    if err
      log_faulty_request(server)

      render :text => "", :status => 400
      return
    end

    render :json => {}
  end

  def show
    server = current_account.agent_servers.where(:uuid => params[:uuid]).take

    bundle = server.system_bundle
    if bundle.nil?
      render :json => {}
    else
      hash = PackageReport.from_bundle(bundle).reduce({}) do  |hash, vp|
        hash[vp.name] = vp.upgrade_to.first
        hash
      end

      render :json => hash
    end
  end

  def fetch_pr_from_server(pr_params, server)
    platform = server.distro
    release = server.release

    case pr_params[:kind]
    when "gemfile"
      platform = "ruby"
      release = nil
    end

    PlatformRelease.validate(platform, release)
  end

  def log_faulty_request(server)
    server.received_files.create(account_id: current_account.id, 
                                 request: request.raw_post)

  end

  def create_params
    params.require(:agent).permit(:hostname, :uname, :ip, :name, :distro, :release)
  end

  def heartbeat_params
    params.require(:agent).permit(:"agent-version", :distro, :release, :files => [:"being-watched", :crc, :kind, :path, :"updated-at"])
  end

  def sendfile_params
    params.require(:agent).permit(:contents, :crc, :kind, :name, :path)
  end
end

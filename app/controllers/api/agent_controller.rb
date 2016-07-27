class Api::AgentController < ApiController
  def heartbeat
    server = AgentServer.where(:uuid => params[:uuid]).includes(:agent_release).take

    # TODO log this?
    unless server
      render :text => "", :status => 404
      return
    end

    # TODO: what do we need to update?
    server.heartbeats.create!(:files => heartbeat_params[:files])

    agent_version = heartbeat_params[:"agent-version"]

    if server.agent_release.nil? || server.agent_release.version != agent_version
      server.agent_release = AgentRelease.where(:version => agent_version).first_or_create
    end

    server.last_heartbeat = Time.now
    server.save!

    render json: {heartbeat: server.last_heartbeat}
  end

  def create
    server = AgentServer.create!(create_params).reload
    render :json => {uuid: server.uuid}
  end

  def update
    server = AgentServer.where(:uuid => params[:uuid]).take
    unless server
      render :text => "", :status => 404
      return
    end

    platform = server.distro
    release = server.release

    case sendfile_params[:kind]
    when "gemfile"
      platform = "ruby"
      release = nil
    end

    pr, err = PlatformRelease.validate(platform, release)

    # TODO: log or show error
    if err
      render :text => "", :status => 400
      return
    end

    parser = Platforms.parser_for(pr.platform)
    file = Base64.decode64(sendfile_params[:contents])

    package_list, err = parser.parse(file)

    # TODO: log or show error?
    if err
      render :text => "", :status => 400
      return
    end

    bundle_opt = {name: sendfile_params[:name], 
                  path: sendfile_params[:path],
                  last_crc: sendfile_params[:crc]}

    bm = BundleManager.new(Account.find(1), server)
    bundle, err = bm.create_or_update(pr, bundle_opt, package_list)
    
    # TODO: again, show error?
    if err
      render :text => "", :status => 400
      return
    end

    render :json => {}
  end

  def show
    # TODO return upgrade-tos
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

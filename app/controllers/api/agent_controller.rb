# TODO: convert to a Form
class Api::AgentController < ApiController
  # This is used for logging dead agents (agents for deleted servers)
  # It was named sigh because Phill was having a bad day
  # TODO: move this to a table. Give things sane names
  def sigh
    @sigh ||= Logger.new(File.join(Rails.root, "log/agenttest.log"))
  end

  def loggit(str, uuid)
    sigh.info("#{current_account.email}:#{uuid} - #{str}")
  end
  
  def heartbeat
    server = current_account.agent_servers.where(:uuid => params[:uuid]).includes(:agent_release).take

    # TODO log this?
    unless server
      loggit("404 <3", params[:uuid])
      render :text => "", :status => 404
      return
    end

    server.register_heartbeat!(params)

    # needs to fetch the newly created heartbeat
    server.reload

    render json: {heartbeat: server.last_heartbeat_at}
  end

  def create
    server = current_account.agent_servers.create!(create_params).reload
    $analytics.added_server(current_account, server)
    render :json => {uuid: server.uuid}
  end

  def update
    server = current_account.agent_servers.where(:uuid => params[:uuid]).take
    unless server
      loggit("404 PUT", params[:uuid])
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
    if err || package_list.empty?
      log_faulty_request(server)
      loggit("400 PUT", params[:uuid])
      render :text => "", :status => 400
      return
    end

    bundle_opt = {name: sendfile_params[:name], 
                  path: sendfile_params[:path],
                  last_crc: sendfile_params[:crc]}
    AgentUpdateJob.enqueue(current_account.id, server.id, Marshal.dump(pr), bundle_opt, Marshal.dump(package_list))
    # bm = BundleManager.new(current_account, server)
    # bundle, err = bm.create_or_update(pr, bundle_opt, package_list)
    
    # if err
    #   log_faulty_request(server)

    #   loggit("400 PUT bundle", params[:uuid])
    #   render :text => "", :status => 400
    #   return
    # end

    log_every_request(server)
    render :json => {}
  end

  def show
    server = current_account.agent_servers.where(:uuid => params[:uuid]).take

    bundle = server.system_bundle
    if bundle.nil?
      render :json => {}
    else
      hash = VulnQuery.patchable_from_bundle(bundle).reduce({}) do  |hash, vp|
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

  def log_every_request(server)
    if $rollout.active?(:log_every_file)
      server.accepted_files.create(account_id: current_account.id, 
                                   request: request.raw_post)
    end
  end

  def log_faulty_request(server)
    server.received_files.create(account_id: current_account.id, 
                                 request: request.raw_post)
   Raven.capture_message("Received faulty file from #{server.account.email}, server id: #{server.id}") 

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

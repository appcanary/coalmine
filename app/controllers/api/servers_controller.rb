class Api::ServersController < ApiController
  def index
    @servers = current_account.agent_servers
    handle_api_response(@servers)
  end

  def show
    if server
      register_api_call!
      handle_api_response(server)
    else
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    end
  end

  def update_procs
    if server.nil?
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    else
      register_api_call!
      # update server with a set of procs here
      server.update_procs(procs_params)
      server.save!
      render :nothing => true, :status => 204
    end
  end

  def destroy
    if server.nil?
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    elsif server.destroy
      $analytics.deleted_server(current_account, server)
      register_api_call!
      render :nothing => true, :status => 204
    else
      render json: {errors: [{title: "Server deletion failed."}]}, adapter: :json_api, status: 500
    end
  end

  def handle_api_response(server_or_servers)
    if v2_request?
      # when calling serializers directly,
      # have to force json here - has to do
      # with how AMS handles the render :json call below
      opt = {}
      opt[:show_action] = (action_name == "show")
      render json: ApiV2ServerResponseSerializer.new(server_or_servers, opt).to_json
    else
      if action_name == "show"
        render :json => server_or_servers, adapter: :json_api, include: [{monitors: [{packages: "vulnerabilities"}]}]
      else
        render :json => server_or_servers, adapter: :json_api, include: ["monitors"], :skip_vulns => true, each_serializer: AgentServerIndexSerializer
      end
    end
  end

  private
  def server
    @server ||= current_account.agent_servers.where(:uuid => params[:uuid]).take
    @server ||= current_account.agent_servers.where(:id => params[:uuid]).take
  end

  def procs_params
    params[:server] && params[:server][:procs]
  end
end

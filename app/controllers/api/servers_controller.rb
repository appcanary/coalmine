class Api::ServersController < ApiController
  def index
    @servers = current_account.agent_servers
    handle_api_response(@servers)
  end

  def show
    @server = fetch_server

    if @server
      register_api_call!
      handle_api_response(@server)
    else
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    end
  end

  def destroy
    @server = fetch_server

    if @server.nil?
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    elsif @server.destroy
      $analytics.deleted_server(current_account, @server)
      register_api_call!
      render :nothing => true, :status => 204
    else
      render json: {errors: [{title: "Server deletion failed."}]}, adapter: :json_api, status: 500
    end
  end

  def destroy_inactive
    if destroyed_servers = current_account.agent_servers.inactive.destroy_all
      destroyed_servers.each do |s|
        $analytics.deleted_server(current_account, s)
      end
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
        render :json => server_or_servers, adapter: :json_api, include: [{monitors: [{packages: "vulnerabilities"}]}], :hide_ignored => params[:hide_ignored]
      else
        render :json => server_or_servers, adapter: :json_api, include: ["monitors"], :skip_vulns => true, each_serializer: AgentServerIndexSerializer,  :hide_ignored => params[:hide_ignored]
      end
    end
  end

  private
  def fetch_server_using(id_key)
    current_account.agent_servers.where(id_key => params[:uuid]).take
  end

  def fetch_server
    fetch_server_using(:id) || fetch_server_using(:uuid)
  end
end

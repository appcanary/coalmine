class Api::ServersController < ApiController
  def index
    @servers = current_account.agent_servers
    render :json => @servers, adapter: :json_api, include: ["monitors"], :skip_vulns => true, each_serializer: AgentServerIndexSerializer
  end

  def show
    @server = current_account.agent_servers.where(:uuid => params[:uuid]).take
    @server ||= current_account.agent_servers.where(:id => params[:uuid]).take

    if @server
      register_api_call!
      render :json => @server, adapter: :json_api, include: [{monitors: [{packages: "vulnerabilities"}]}]
    else
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    end
  end

  def destroy
    @server = current_account.agent_servers.where(:uuid => params[:uuid]).take
    @server ||= current_account.agent_servers.where(:id => params[:uuid]).take

    if @server.nil?
      render json: {errors: [{title: "No server with that id was found"}]}, adapter: :json_api, status: :not_found
    elsif @server.destroy
      register_api_call!
      render :nothing => true, :status => 204
    else
      render json: {errors: [{title: "Server deletion failed."}]}, adapter: :json_api, status: 500
    end
  end
end

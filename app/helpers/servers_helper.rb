module ServersHelper
  def server_processes(server_presenter)
    if params[:debug_server_processes]
      server_presenter.all_processes
    else
      server_presenter.outdated_processes
    end
  end
end

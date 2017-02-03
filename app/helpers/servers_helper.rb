module ServersHelper
  def server_processes(server_presenter)
    if debug_server_processes?
      server_presenter.all_processes
    else
      server_presenter.outdated_processes
    end
  end

  def debug_server_processes?
    params[:debug_server_processes].present?
  end
end

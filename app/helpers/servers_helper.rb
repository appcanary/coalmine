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

  def hide_deploy_opt_klass(user, deployer, *platforms)
    ret = platforms.dup
    if user.pref_deploy != deployer
      ret << "collapse"
    else
      if !platforms.present? 
        ret << "collapse in"
      else
        if !platforms.include?(user.pref_os)
          ret << "collapse"
        else
          ret << "collapse in"
        end
      end
    end

    ret.join(" ")
  end
end

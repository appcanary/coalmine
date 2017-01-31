module ServersHelper
  def hide_deploy_opt_klass(user, deployer, *platforms)
    ret = platforms.dup
    if user.pref_deploy != deployer
      ret << "collapse"
    else
      if platforms.present? 
        if !platforms.include?(user.pref_os)
          ret << "collapse"
        end
      end
    end

    ret.join(" ")
  end
end

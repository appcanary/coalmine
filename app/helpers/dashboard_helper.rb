module DashboardHelper
  def at_a_glance(monitor_presenters, server_presenters)
    active_servers = server_presenters.active_servers
    silenced_servers = server_presenters.silent_servers

    total_monitored = active_servers.count + silenced_servers.count + monitor_presenters.count

    vuln_servers = active_servers.select(&:vulnerable?).count 
    miss_servers = silenced_servers.count 
    
    vuln_monitors = monitor_presenters.select(&:vulnerable?).count

    html = []

    html << "watching <span class='label label-default'>#{total_monitored} items</span>" 

    if vuln_servers > 0
      html << "<span class='label label-danger'>#{vuln_servers} vulnerable servers</span>"
    end

     if vuln_monitors > 0
      html << "<span class='label label-danger'>#{vuln_monitors} vulnerable monitors</span>"
    end


    if miss_servers > 0
      html << "<span class='label label-warning'>#{miss_servers} servers that have stopped responding</span>"
    end

    html.to_sentence.html_safe
  end

  def monitor_kind_label(monitor)
    platform_label(monitor.platform)
  end

  def platform_label(platform)
    icon, label = case platform
                  when "ruby"
                    ["ruby.png", "Ruby"]
                  when "php"
                    ["php.png", "PHP"]
                  when "centos"
                    ["centos.png", "CentOS"]
                  when "ubuntu"
                    ["ubuntu.png", "Ubuntu"]
                  when "debian"
                    ["debian.png", "Debian"]
                  when "amzn"
                    ["amzn.png", "Amazon Linux"]
                  when "alpine"
                    ["alpine.png", "Alpine Linux"]
                  end

    content_tag(:span) do 
      image_tag("icon-#{icon}", :style => "width: 13px") + " #{label}"
    end
  end
end

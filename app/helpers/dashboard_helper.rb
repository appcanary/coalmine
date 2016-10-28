module DashboardHelper
  def at_a_glance(monitors, servers)
    active_servers = servers.active_servers
    silenced_servers = servers.silent_servers

    total_monitored = active_servers.count + silenced_servers.count + monitors.count

    vuln_servers = active_servers.select(&:vulnerable?).count 
    miss_servers = silenced_servers.count 
    
    vuln_monitors = monitors.select(&:vulnerable?).count

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
    icon, label = case monitor.platform
                  when "ruby"
                    ["ruby.png", "Ruby"]
                  when "centos"
                    ["centos.png", "CentOS"]
                  when "ubuntu"
                    ["ubuntu.png", "Ubuntu"]
                  when "debian"
                    ["debian.png", "Ubuntu"]
                  when "amzn"
                    ["amzn.png", "Amazon Linux"]
                  end

    content_tag(:span) do 
      image_tag("icon-#{icon}", :style => "width: 13px") + " #{label}"
    end
  end
end

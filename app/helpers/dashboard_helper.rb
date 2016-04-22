module DashboardHelper
  def at_a_glance(monitors, active_servers, silenced_servers)

    total_monitored = active_servers.count + silenced_servers.count + monitors.count

    vuln_servers = active_servers.select(&:vulnerable).count 
    miss_servers = silenced_servers.count 
    
    vuln_monitors = monitors.select(&:vulnerable).count

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
    img_str = case monitor.kind
    when "ruby"
      image_tag("icon-ruby.png", :style => "width: 13px") + " Ruby"
    when "centos"
      image_tag("icon-centos.png", :style => "width: 13px") + " CentOS"
    when "ubuntu"
      image_tag("icon-ubuntu.png", :style => "width: 13px") + " Ubuntu`"
    end

    content_tag(:span) do 
      img_str
    end
  end
end

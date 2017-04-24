module DailySummaryMailerHelper
  def servers_and_or_monitors(server_ct, monitor_ct)
    if server_ct > 0 && monitor_ct > 0
      "<b>#{pluralize server_ct, 'server'}</b> and <b>#{pluralize monitor_ct, 'monitor'}</b>".html_safe
    elsif monitor_ct > 0
      "<b>#{pluralize monitor_ct, 'monitor'}</b>".html_safe
    else
      "<b>#{pluralize server_ct, 'server'}</b>".html_safe
    end
  end
end

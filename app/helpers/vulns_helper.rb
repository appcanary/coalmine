module VulnsHelper
  def make_related_links_list(links)
    # Makes a list of links into HTML links (filtering our invalid ones)
    links.map { |url|
      if host = get_host_without_www(url)
        ActionController::Base.helpers.link_to(host, url, target: "_blank")
      else
        nil
      end
    }.compact.join(", ").html_safe

  end

  def get_host_without_www(refurl)
    url = refurl
    url = "http://#{url}" unless url.start_with?('http')
    try_ct = 0
    begin
      uri = URI.parse(url)
      host = uri.host.downcase
      host.start_with?('www.') ? host[4..-1] : host
    rescue URI::InvalidURIError => e
      # some of these things have spaces in them
      possible_urls = url.split(/\s+/)

      # paranoid but I don't feel comfortable
      # leaning on the size of "possible_urls"
      if try_ct < 1
        try_ct += 1
        url = possible_urls.first
        retry
      else
        nil
      end
    end
  end

end

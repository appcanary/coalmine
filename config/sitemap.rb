# Set the host name for URL creation
if Rails.env.production?
  SitemapGenerator::Sitemap.default_host = "https://appcanary.com"
else
  # lol do nothing
  exit 0
end

SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  #

  add '/solutions/soc2', :priority => 0.8, :lastmod => File.mtime("app/views/soc2/index.html.erb")
  add '/pricing', :changefreq => 'monthly', :lastmod => File.mtime("app/views/welcome/index.html.erb")

  add '/legal/privacy', :changefreq => 'yearly', :lastmod => File.mtime("app/views/static/privacy.html.erb")


  add '/docs', :lastmod => File.mtime("app/views/docs/index.html.erb")
  add '/docs/api', :lastmod => File.mtime("app/views/docs/api.html.erb")
  add '/docs/ci', :lastmod => File.mtime("app/views/docs/ci.html.erb")
  add '/docs/agent', :lastmod => File.mtime("app/views/docs/agent.html.erb")
  add '/docs/agent_upgrade', :lastmod => File.mtime("app/views/docs/agent_upgrade.html.erb")

  add '/vulns', :changefreq => 'daily'
  Vulnerability.find_each do |vuln|
    opt = {}
    opt[:lastmod] = vuln.updated_at

    if vuln.updated_at > 1.month.ago
      opt[:changefreq] = 'daily'
    end

    add vuln_path(vuln), opt
  end

  Advisory.from_cve.find_each do |cve|
    add cve_path(cve.identifier), :lastmod => cve.updated_at
  end
end

# http://stackoverflow.com/questions/33043106/recommended-way-to-use-rails-view-helpers-in-a-presentation-class
class VulnPresenter
  delegate :title, :platform, :criticality, :reported_at, :updated_at, :expired_at, :packages, :source, :criticality, :archives, :id, :current, :related_vulns, :to => :vuln
  attr_reader :vuln
  def initialize(vuln, archive = false)
    @vuln = vuln
    @is_archive = archive
  end

  def canary_id
    "CNY-#{@vuln.id}"
  end

  def archive?
    @is_archive
  end

  def vulnerable_dependencies
    @vuln.vulnerable_dependencies.order("release, package_name")
  end

  def package_names
    @vuln.package_names.join(", ")
  end

  def related_links
    @vuln.related.map { |url|
      if host = get_host_without_www(url)
        h.link_to(host, url, target: "_blank")
      else
        nil
      end
    }.compact.join(", ").html_safe
  end

  def has_cves?
    cve_references.present?
  end

  def cve_references
    @vuln.cve_ids
  end

  def cvss
    @vuln.cvss || "Unknown"
  end

  def description
    if @vuln.description
      @vuln.description.lines.join("<br/>").html_safe
    else
      ""
    end
  end

  def advisory
    @vuln.advisories.first
  end

  def show_unaffected?
    Platforms::PLATFORMS_WITH_UNAFFECTED.include? self.platform
  end

  def show_release?
    Platforms::PLATFORMS_WITH_RELEASES.include? self.platform 
  end

  def h
    ActionController::Base.helpers
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

# http://stackoverflow.com/questions/33043106/recommended-way-to-use-rails-view-helpers-in-a-presentation-class
class VulnPresenter
  delegate :title, :platform, :criticality, :vulnerable_dependencies, :reported_at, :packages, :source, :criticality, :to => :vuln
  attr_reader :vuln
  def initialize(vuln)
    @vuln = vuln
  end

  def canary_id
    "CNY-#{@vuln.id}"
  end

  def description
    @vuln.description.html_safe
  end

  def dependency_names
    @vuln.vulnerable_dependency_names.join(", ")
  end

  def related_links
    @vuln.related.map { |url|
      h.link_to(get_host_without_www(url), url, target: "blank")
    }.join(", ").html_safe
  end

  def has_cves?
    cve_references.present?
  end

  def cve_links
    cve_references.map { |cve| 
      h.link_to(cve, "https://web.nvd.nist.gov/view/vuln/detail?vulnId=#{cve}", target: "blank")
    }
  end

  def cve_references
    @cve_references ||= @vuln.reference_ids.select { |s| s =~ /CVE/ }
  end

  def description
    if @vuln.description
      @vuln.description.lines.join("<br/>").html_safe
    else
      ""
    end
  end

  def h
    ActionController::Base.helpers
  end

  def get_host_without_www(url)
    url = "http://#{url}" unless url.start_with?('http')
    uri = URI.parse(url)
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end
end

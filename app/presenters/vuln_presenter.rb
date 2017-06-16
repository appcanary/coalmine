# http://stackoverflow.com/questions/33043106/recommended-way-to-use-rails-view-helpers-in-a-presentation-class
class VulnPresenter
  include VulnsHelper
  delegate :title, :platform, :criticality, :reported_at, :updated_at, :expired_at, :packages, :source, :criticality, :archives, :id, :current, :to => :vuln
  attr_reader :vuln
  def initialize(vuln, archive = false)
    @vuln = vuln
    @is_archive = archive
    @current_vuln = self.archive? ? @vuln.current : @vuln
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
    make_related_links_list @vuln.related
  end

  def cve_references
   # Note we pull the cves from the current vuln
   @current_vuln.cve_references
  end

  def has_cves?
    self.cve_references.present?
  end

  def related_vulns
    Vulnerability.by_cve_ids(self.cve_references).reject { |v| v.id == @current_vuln.id}
  end

  def cvss
    @vuln.cvss || "unknown"
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
end

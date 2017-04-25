class RHSAImporter < AdvisoryImporter
  SOURCE = "rhsa"
  PLATFORM = Platforms::CentOS
  RHSD_CVE_ENDPOINT = "https://access.redhat.com/labs/securitydataapi"

  def self.first_import!
    RHSAImporter.new(Time.at(0)).import!
  end

  attr_reader :after

  def initialize(after = nil)
    @after = after || 2.hours.ago
  end

  def fetch_advisories
    page = 1
    per_page = 1000

    results = []

    loop do
      params = {
        params: {
          per_page: per_page,
          page: page,
          after: after.iso8601
        }
      }

      xml = RestClient.get("#{RHSD_CVE_ENDPOINT}/cvrf.xml", params)
      this_page = Nokogiri::XML(xml)
      results = results.concat(this_page.css("Cvrfs Cvrf"))

      # no more pages
      break if this_page.count < per_page
    end

    results
  end

  def parse(rhsa)
    resource_url = rhsa.at_xpath("//Cvrf/ResourceUrl").text
    xml = RestClient.get(resource_url)
    cvrfdoc = Nokogiri::XML(xml).at_css("cvrfdoc")

    hsh = {
      "rhsa_id"     => rhsa.css("RHSA").text,
      "cves"        => rhsa.css("CVEs CVE").map(&:text),
      "title"       => cvrfdoc.css("DocumentTitle").text,
      "severity"    => rhsa.css("Severity").text,
      "released_on" => rhsa.css("ReleasedOn").text,
      "references"  => cvrfdoc.css("DocumentReferences Reference URL").map(&:text),
      "description" => cvrfdoc.css("DocumentNotes Note").
                         sort_by {|v| v.attr("Ordinal").to_i}.
                         map(&:text).
                         join("\n")
    }

    RHSAAdapter.new(hsh, xml)
  end
end

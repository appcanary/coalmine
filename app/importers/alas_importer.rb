require 'open-uri'
class AlasImporter < AdvisoryImporter
  SOURCE = "alas"
  PLATFORM = Platforms::Amazon
  URL = "https://alas.aws.amazon.com/index.html"

  def initialize(url = nil)
    @index_url = url || URL
    @base_url = File.dirname(@index_url)
  end

  def fetch_advisories
    alas_index = open(@index_url).read

    document = Nokogiri::HTML.parse(alas_index)
    # there is an #ALAStable, whose first row is a column header
    # that lists every advisory it knows about
    alas_paths = document.css("#ALAStable tr")[1..-1].map do |row| 
      row.css("a").first.attributes["href"].value
    end

    alas_urls = alas_paths.map { |s|
      # don't look now but using File rather than
      # URI lets this work both for http and for local
      # files, i.e. when testing
      File.join(@base_url, s).to_s
    }
  end

  def parse(adv_url)
    html = open(adv_url).read
    document = Nokogiri::HTML.parse(html)

    alas_info = document.css(".alas-info").map(&:inner_text)
    alas_id_str, released_at_str, _ = alas_info

    alas_id = alas_id_str.match(/ALAS-(\d+)-(\d+)/).to_s
    released_at = released_at_str.match(/\d\d\d\d-\d\d-.*$/).to_s

    severity = document.css("#severity").first.children[4].text.strip

    reference_ids = document.css("#references a").map { |cve| 
      cve.text.gsub(/\p{Space}/, "")
    } 
 
    # [2..-1] to skip over <b>Issue Overview</b>
    description = document.css("#issue_overview").children[2..-1].inner_text.strip
 
    remediation = document.css("#issue_correction i").map(&:text).join(", ")

    affected_packages = document.css("#affected_packages p").text.split(",")

    new_packages = document.css("#new_packages pre").first.children
    # reject new lines and the arch: formatting, cos arch info is
    # already in the filenames i.e.
    # i686:
    #   foo-bar-1.2.3-4.567.amzn1.i686
    new_packages = new_packages.select { |c| c.name != "br" && !(c.text =~ /:/) }
    
    # strip whitespace
    new_packages = new_packages.map do |p|
      p.text.gsub(/\p{Space}/, "")
    end

    # TODO: handle affected??
    AlasAdapter.new({
      "alas_id" => alas_id,
      "released_at" => released_at,
      "severity" => severity,
      "reference_ids" => reference_ids,
      "description" => description,
      "affected_packages" => affected_packages,
      "new_packages" => new_packages,
      "remediation" => remediation,
    }, html)
  end
end

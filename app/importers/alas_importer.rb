require 'open-uri'
class AlasImporter
  SOURCE = "alas"
  URL = "https://alas.aws.amazon.com/index.html"

  def initialize(url = nil)
    @index_url = url || URL
    @base_url = File.dirname(url)
  end

  def import!
    raw_advisories = fetch_advisories
    all_advisories = raw_advisories.map { |ra| parse(ra) }
    process_advisories(all_advisories)
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

    cve_ids = document.css("#references a").map { |cve| 
      cve.text.gsub(/\p{Space}/, "")
    } 
 
    # [2..-1] to skip over <b>Issue Overview</b>
    description = document.css("#issue_overview").children[2..-1].inner_text.strip

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
    AlasAdvisory.new({
      "alas_id" => alas_id,
      "released_at" => released_at,
      "severity" => severity,
      "cve_ids" => cve_ids,
      "description" => description,
      # "affected_packages" => affected_packages,
      "new_packages" => new_packages,
    })
  end

  def process_advisories(all_advisories)
    all_advisories.each do |adv|
      qadv = QueuedAdvisory.most_recent_advisory_for(adv.identifier, SOURCE).first

      if qadv.nil?
        # oh look, a new advisory!
        QueuedAdvisory.create!(adv.to_advisory_attributes)
      else
        if has_changed?(qadv, adv)
          QueuedAdvisory.create!(adv.to_advisory_attributes)
        end
      end
    end
  end

  def has_changed?(existing_advisory, adv)
    new_attributes = adv.to_advisory_attributes
    relevant_attributes = existing_advisory.attributes.keep_if { |k, _| new_attributes.key?(k) }

    relevant_attributes != new_attributes
  end


  class AlasAdvisory
    ATTR = ['alas_id', 'cve_ids', 'severity', 'released_at', 
            'description', 'affected_packages', 'new_packages']
    ATTR_LOOKUP = Hash[ ATTR.map { |attr| [attr, true] } ]
    attr_accessor *ATTR.map(&:to_sym)

    def initialize(hsh)
      hsh.each_pair do |k, v|
        if ATTR_LOOKUP[k]
          self.send("#{k}=", v)
        end
      end
    end

    def identifier
      alas_id
    end

    def reported_at
      DateTime.parse(released_at).utc
    end

    def affected
      # ??
    end

    def patched
      new_packages.map { |p|
        {"filename" => p}
      }
    end

    def generate_criticality
      if severity
        severity.downcase
      else
        "unknown"
      end
    end

    def to_advisory_attributes
      @advisory_attributes ||=
        {
          "identifier" => alas_id,
          "package_platform" => Platforms::Amazon,
          "reported_at" => reported_at,
          "criticality" => generate_criticality,
          "cve_ids" => cve_ids,
          "description" => description,
          # "affected" => affected,
          "patched" => patched,
          "source" => SOURCE
      }
    end
  end
end

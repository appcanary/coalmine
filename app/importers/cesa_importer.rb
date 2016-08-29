class CesaImporter
  SOURCE = "cesa"
  REPO_URL = "https://github.com/stevemeier/cefs.git"
  REPO_PATH = "tmp/importer/cefs"

  ERRATA_PATH = File.join(REPO_PATH, "errata.latest.xml")

  def import!
    git = GitHandler.new(self.class, REPO_URL, local_path)
    git.fetch_and_update_repo!

    errata_file = File.open(errata_path, "r")
    document = Nokogiri::XML.parse(errata_file)

    cesa_elements = fetch_cesa_elements(document)
    all_advisories = load_advisories(cesa_elements)

    process_advisories(all_advisories)
  end

  def local_path
    File.join(Rails.root, REPO_PATH)
  end

  def errata_path
    File.join(Rails.root, ERRATA_PATH)
  end

  def fetch_cesa_elements(document)
    document.elements.first.elements.select { |e|
      e.name =~ /CESA-(\d+)--(.+)/
    }
  end

  def load_advisories(cesa_elements)
    cesa_elements.map do |cesa|
      cesa_id = cesa.name

      attr = cesa.attributes

      issue_date = attr["issue_date"].value

      if issue_date
        issue_date = DateTime.parse(issue_date)
      end

      os_arches = cesa.xpath('os_arch').map(&:text)
      os_releases = cesa.xpath('os_release').map(&:text)
      packages = cesa.xpath('packages').map(&:text)
      severity = attr["severity"].try(:value)
      synopsis = attr["synopsis"].value
  

      CesaAdvisory.new({
        "cesa_id" => cesa_id,
        "issue_date" => issue_date,
        "os_arches" => os_arches,
        "os_releases" => os_releases,
        "packages" => packages,
        "severity" => severity,
        "synopsis" => synopsis,
      })
    end
  end

  def process_advisories(all_advisories)
    all_advisories.each do |adv|
      if qadv = QueuedAdvisory.most_recent_advisory_for(adv.identifier, SOURCE).first
        new_attributes = adv.to_advisory_attributes

        if has_changed?(qadv, new_attributes)
          QueuedAdvisory.create!(new_attributes)
        end
        # else. do nothing.
      else
        # oh look, a new advisory!
        QueuedAdvisory.create!(adv.to_advisory_attributes)
      end
    end
  end

  def has_changed?(existing_advisory, new_attributes)
    relevant_attributes = existing_advisory.attributes.keep_if { |k, _| new_attributes.key?(k) }
    
    relevant_attributes != new_attributes
  end

  class CesaAdvisory
    ATTR = ['cesa_id', 'issue_date', 'synopsis', 'severity', 'os_arches', 'os_releases', 'packages']
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
      generate_cesa_id
    end

    def generate_patched
      packages.map { |p|
        {"filename" => p}
      }
    end

    def generate_affected
      os_arches.map do |arch|
        os_releases.map do |rel|
          {"arch" => arch, "release" => rel}
        end
      end.flatten
    end

    def generate_criticality
      case severity
      when "Critical"
        "critical"
      when "Important"
        "high"
      when "Moderate"
        "medium"
      when "Low"
        "low"
      else
        "unknown"
      end
    end

    def generate_cesa_id
      @gen_cesa_id ||= cesa_id.gsub("--", ":")
    end

    def to_advisory_attributes
      {
        "identifier" => identifier,
        "package_platform" => Platforms::CentOS,
        "patched" => generate_patched,
        "affected" => generate_affected,
        "criticality" => generate_criticality,
        "reported_at" => issue_date,
        "title" => synopsis,
        "cesa_id" => generate_cesa_id,
        "source" => SOURCE
      }

    end

  end
end

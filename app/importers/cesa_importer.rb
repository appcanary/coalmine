class CesaImporter < AdvisoryImporter
  SOURCE = "cesa"
  REPO_URL = "https://github.com/stevemeier/cefs.git"
  REPO_PATH = "tmp/importers/cefs"

  ERRATA_PATH =  "errata.latest.xml"

  def initialize(repo_path = nil, repo_url = nil)
    @repo_url = repo_url || REPO_URL
    @repo_path = repo_path || REPO_PATH
  end

  def local_path
    File.join(Rails.root, @repo_path)
  end

  def errata_path
    File.join(Rails.root, @repo_path, ERRATA_PATH)
  end

  def update_local_store!
    git = GitHandler.new(self.class, @repo_url, local_path)
    git.fetch_and_update_repo!
  end

  def fetch_advisories
    errata_file = File.open(errata_path, "r")
    document = Nokogiri::XML.parse(errata_file)

    cesa_elements = fetch_cesa_elements(document)
  end

  def fetch_cesa_elements(document)
    document.elements.first.elements.select { |e|
      e.name =~ /CESA-(\d+)--(.+)/
    }
  end

  def parse(cesa)
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

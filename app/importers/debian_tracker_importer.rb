require 'open-uri'
class DebianTrackerImporter < AdvisoryImporter
  SOURCE = "debian-tracker"
  PLATFORM = Platforms::Debian
  URL = "https://security-tracker.debian.org/tracker/data/json"
  # URL = File.join(Rails.root, "tmp/importers/debian-security-tracker.json")

  def initialize(url = nil)
    @index_url = url || URL
  end

  def fetch_advisories
    # structure is
    # package_name: { CVE-1: {}, CVE-2: {} }
    JSON.parse(open(@index_url).read).
      reduce([]) do |arr, (pkg, hsh)|
      hsh.each_pair do |cve, attr|
        arr << attr.merge("cve" => cve, "package_name" => pkg)
      end
      arr
    end
  end

  def parse(hsh)
    DebianTrackerAdapter.new(hsh, hsh)
  end
end

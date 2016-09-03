require 'open-uri'
class DebianTrackerImporter < AdvisoryImporter
  SOURCE = "debian-tracker"
  # URL = "https://security-tracker.debian.org/tracker/data/json"
  URL = File.join(Rails.root, "tmp/importers/debian-security-tracker.json")

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
    DebianTrackerAdvisory.new(hsh, hsh)
  end

  # def process_advisories(all_advs)
  #   all_advs.reduce({}) do |h, adv|
  #     adv["releases"].each do |rel, attr|
  #       h[attr["status"]] ||= []
  #       h[attr["status"]] << adv
  #     end

  #     # urgs = adv["releases"].map { |n, a| a["urgency"] }
  #     # first_ur = urgs.first

  #     # not_same = adv["releases"].any? do |rel, attr|
  #     #   attr["urgency"] != first_ur
  #     # end
  #     # if not_same
  #     #   puts "not same: #{adv["package_name"]} #{adv["cve"]} #{urgs}"
  #     # end
  #     h
  #   end

  # end
end

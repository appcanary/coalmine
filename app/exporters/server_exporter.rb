# TODO: merge into serializers folder?
require 'csv'
class ServerExporter
  attr_accessor :server, :vulns
  def initialize(server, vulns)
    self.server = server
    self.vulns = vulns
  end

  def to_csv
    output = CSV.generate(headers: true) do |csv|
      csv << ["Name", "Last Heartbeat", "Distro / Release", "Vulnerable?"]

      csv << [server.display_name,
              server.last_heartbeat_at,
              "#{server.distro} / #{server.release}",
              server.vulnerable?]

      csv << [""]

      csv << ["Path", "Package", "CVE", "Upgrade to", "Title"]
      
      vulns.each do |vp|
        csv << [vp.bundle.path, vp.package.name, vp.vulnerability.cve_ids.join(", "), vp.package.upgrade_to.join(", "), vp.vulnerability.title]
      end
    end

    [output, {filename: "appcanary-server-#{server.display_name}-#{Date.today}.csv"}]
  end
end

# TODO: merge into serializers folder?
require 'csv'
class ServerExporter
  attr_accessor :server, :bundle_and_pkgs
  def initialize(server, bundle_and_pkgs)
    self.server = server
    self.bundle_and_pkgs = bundle_and_pkgs
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
      
      bundle_and_pkgs.each do |bundle, packages|
        packages.each do |pkg|
          pkg.vulnerabilities.each do |vuln|
            csv << [bundle.path, pkg.name, vuln.cve_ids.join(", "), pkg.upgrade_to.join(", "), vuln.title]
          end
        end
      end
    end

    [output, {filename: "appcanary-server-#{server.display_name}-#{Date.today}.csv"}]
  end
end

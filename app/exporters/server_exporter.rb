require 'csv'
class ServerExporter
  attr_accessor :server, :apps
  def initialize(server, apps)
    self.server = server
    self.apps = apps
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
      apps.each do |a|
        a.vulnerable_packages.each do |vp|
          vp.vulnerabilities.each do |vuln|
            csv << [a.path, vp.name, vuln.cve_id, vuln.upgrade_to.try(:join, ", "), vuln.title]
          end
        end
      end
    end

    [output, {filename: "appcanary-server-#{server.display_name}-#{Date.today}.csv"}]
  end
end

# TODO: merge into serializers folder?
require 'csv'
class MasterReporter
  attr_accessor :account
  def initialize(account)
    self.account = account
  end

  def to_csv
    vq = VulnQuery.new(account)

    output = CSV.generate(headers: true) do |csv|
      account.bundles.each do |bundle|

        unless bundle.isactive?
          next
        end

        isvuln = vq.vuln_bundle?(bundle)

        csv << ["Server or Monitor", "Updated At", "Distro / Release", "Vulnerable?"]

        csv << [bundle.ref_name,
                bundle.updated_at,
                [bundle.platform, bundle.release].compact.join(" / "),
                isvuln]

        if isvuln
          csv << [""]

          csv << ["Package", "Severity", "CVE", "Upgrade to"]
          pkgs = vq.from_bundle(bundle)

          pkgs.each do |pkg|
            pkg.vulnerabilities.each do |vuln|
              csv << [pkg.name, vuln.criticality, vuln.reference_ids.join(", "), pkg.upgrade_to.join(", ")]
            end
          end

        end

        csv << [""]
        csv << [""]
      end
    end

    [output, {filename: "appcanary-#{account.email}-#{Date.today}.csv"}]
  end
end

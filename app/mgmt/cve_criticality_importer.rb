class CveCriticalityImporter
  def self.import_criticalities
    # limit ourselves to advisories that have corresponding vulns
    Advisory.from_cve.unprocessed.joins("INNER JOIN vulnerabilities ON advisories.identifier = ANY(vulnerabilities.reference_ids)").uniq.find_each do |cve|
      cve.transaction do
        vulns = Vulnerability.by_cve_id(cve.identifier)
        vulns.find_each do |vuln|
          criticality, cvss = VulnerabilityManager.compute_max_crit_cvss(vuln, cve)
          vuln.criticality = criticality
          vuln.cvss = cvss
          vuln.save!
        end
        cve.advisory_import_state.update_attributes!(processed: true)
      end
    end
  end
end

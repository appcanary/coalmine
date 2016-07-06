class ReportManager
  attr_accessor :bundle_id
  def initialize(bundle_id = nil)
    self.bundle_id = bundle_id
  end

  def on_vulnerability_change(vuln_id)
    LogBundleVulnerability.record_vulnerability!(vuln_id)
  end

  def on_bundle_change
    LogBundleVulnerability.record_bundle_vulnerabilities!(bundle_id)
    LogBundlePatch.record_bundle_patches!(bundle_id)
  end
end

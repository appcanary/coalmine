class LogMaker < ServiceMaker
  def on_vulnerability_change(vuln_id)
    LogBundleVulnerability.record_vulnerability!(vuln_id)
    LogBundlePatch.record_vulnerability_change!(vuln_id)
  end

  def on_bundle_change(bundle_id)
    LogBundleVulnerability.record_bundle_vulnerabilities!(bundle_id)
    LogBundlePatch.record_bundle_patches!(bundle_id)
  end
end

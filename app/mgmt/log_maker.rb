class LogMaker < ServiceMaker
  attr_accessor :bundle, :vulnerability
  def initialize(bundle_id: nil, vulnerability_id: nil)
    if !(bundle_id.present? ^ vulnerability_id.present?)
      raise "LogMaker must be initialized with a bundle_id or vulnerability_id (but not both)"
    end

    if bundle_id
      @bundle = Bundle.find(bundle_id)
    else
      @vulnerability = Vulnerability.find(vulnerability_id)
    end
  end

  def make_logs!
    # We either logs after a bundle changed
    if @bundle.present?
      LogBundleVulnerability.record_bundle_vulnerabilities!(@bundle.id)
      LogBundlePatch.record_bundle_patches!(@bundle.id)

    # of we're updating logs after a vuln changed
    elsif @vulnerability.present?
      LogBundleVulnerability.record_vulnerability!(@vulnerability.id)
      LogBundlePatch.record_vulnerability_change!(@vulnerability.id)      
    end
  end
end

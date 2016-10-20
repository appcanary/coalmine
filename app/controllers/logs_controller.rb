class LogsController < ApplicationController
  def index
    @patch_logs = LogBundlePatch.joins("left join bundles on bundles.id = log_bundle_patches.bundle_id").where("bundles.account_id = ?", current_user.account.id).order(:created_at).includes({bundle: :agent_server}, :package, :vulnerable_dependency, :vulnerability)


    @vuln_logs = LogBundleVulnerability.joins("left join bundles on bundles.id = log_bundle_vulnerabilities.bundle_id").where("bundles.account_id = ?", current_user.account.id).order(:created_at).includes({bundle: :agent_server}, :package, :vulnerable_dependency, :vulnerability)
  end
end
